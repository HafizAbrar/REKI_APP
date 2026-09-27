import 'dart:io';

void main(List<String> arguments) {
  final minimum = arguments.isEmpty ? 80.0 : double.parse(arguments.first);
  final report = File('coverage/lcov.info');
  if (!report.existsSync()) {
    stderr.writeln('Coverage report not found: ${report.path}');
    exitCode = 2;
    return;
  }

  var linesFound = 0;
  var linesHit = 0;
  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    }
  }

  final coverage = linesFound == 0 ? 0.0 : linesHit * 100 / linesFound;
  stdout.writeln(
    'Line coverage: ${coverage.toStringAsFixed(2)}% '
    '(minimum ${minimum.toStringAsFixed(2)}%)',
  );
  if (coverage < minimum) exitCode = 1;
}
