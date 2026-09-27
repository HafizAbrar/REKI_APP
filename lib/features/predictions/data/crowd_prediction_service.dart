import 'dart:math';

/// Phase 7 — Predictive AI: crowd level prediction.
///
/// A simple, transparent model: per-weekday × per-hour mean busyness learned
/// from historical snapshots. The backend-supplied history (when available,
/// GET /venues/{id}/busyness/history) is authoritative; the client keeps a
/// rolling local history as fallback. Confidence reflects sample count.
class CrowdObservation {
  final DateTime timestamp;

  /// Busyness level: 0 = quiet, 1 = moderate, 2 = busy.
  final int level;

  const CrowdObservation(this.timestamp, this.level);

  factory CrowdObservation.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['level'] ?? json['busyness'];
    final level = rawLevel is num
        ? rawLevel.toInt()
        : switch (rawLevel?.toString().toLowerCase()) {
            'busy' => 2,
            'moderate' => 1,
            _ => 0,
          };
    return CrowdObservation(
      DateTime.parse(json['timestamp'].toString()),
      level.clamp(0, 2),
    );
  }
}

class CrowdPrediction {
  /// Predicted level at [forTime]: 0 quiet, 1 moderate, 2 busy.
  final double level;
  final double confidence; // 0..1
  final DateTime forTime;

  const CrowdPrediction({
    required this.level,
    required this.confidence,
    required this.forTime,
  });

  factory CrowdPrediction.fromBackend(
    Map<String, dynamic> json, {
    DateTime? fallbackTime,
  }) {
    final percentage = (json['expectedPercentage'] as num?)?.toDouble();
    final label = json['predictedLevel']?.toString().toLowerCase();
    final level = switch (label) {
      'busy' => 2.0,
      'moderate' => 1.0,
      'quiet' => 0.0,
      _ => percentage == null ? 1.0 : (percentage / 50).clamp(0, 2).toDouble(),
    };
    return CrowdPrediction(
      level: level,
      confidence: ((json['confidence'] as num?)?.toDouble() ?? 0)
          .clamp(0, 1)
          .toDouble(),
      forTime: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          fallbackTime ??
          DateTime.now(),
    );
  }

  String get label {
    if (level < 0.75) return 'Quiet';
    if (level < 1.5) return 'Moderate';
    return 'Busy';
  }
}

class CrowdPredictionModel {
  /// Mean level per (weekday, hour); null = no samples.
  final List<List<double?>> _means =
      List.generate(7, (_) => List<double?>.filled(24, null));
  final List<List<int>> _counts =
      List.generate(7, (_) => List<int>.filled(24, 0));
  double? _globalMean;
  int _totalSamples = 0;

  void train(List<CrowdObservation> observations) {
    // Incremental batch training: simple running means.
    final sums = List.generate(7, (_) => List<double>.filled(24, 0));
    final counts = List.generate(7, (_) => List<int>.filled(24, 0));
    var total = 0.0;
    var n = 0;
    for (final o in observations) {
      final weekday = o.timestamp.weekday - 1; // DateTime weekday 1..7
      sums[weekday][o.timestamp.hour] += o.level;
      counts[weekday][o.timestamp.hour]++;
      total += o.level;
      n++;
    }
    for (var d = 0; d < 7; d++) {
      for (var h = 0; h < 24; h++) {
        _counts[d][h] = counts[d][h];
        _means[d][h] = counts[d][h] > 0 ? sums[d][h] / counts[d][h] : null;
      }
    }
    _globalMean = n > 0 ? total / n : null;
    _totalSamples = n;
  }

  CrowdPrediction predict(DateTime time) {
    final weekday = time.weekday - 1;
    final cellMean = _means[weekday][time.hour];
    if (cellMean != null) {
      final confidence = _confidenceFor(_counts[weekday][time.hour]);
      return CrowdPrediction(
          level: cellMean, confidence: confidence, forTime: time);
    }
    // Fallback: adjacent-hour smoothing, then global mean, then neutral.
    final smoothed = _smoothed(weekday, time.hour);
    return CrowdPrediction(
      level: smoothed ?? _globalMean ?? 1.0,
      confidence:
          smoothed == null ? _confidenceFor(_totalSamples ~/ (7 * 24)) : 0.3,
      forTime: time,
    );
  }

  double? _smoothed(int weekday, int hour) {
    final values = <double>[
      if (_means[weekday][(hour + 23) % 24] != null)
        _means[weekday][(hour + 23) % 24]!,
      if (_means[weekday][(hour + 1) % 24] != null)
        _means[weekday][(hour + 1) % 24]!,
    ];
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _confidenceFor(int samples) =>
      min(samples / 20.0, 1.0); // full confidence from ~20 samples

  int get totalSamples => _totalSamples;
}
