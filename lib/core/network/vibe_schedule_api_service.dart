import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vibe_schedule.dart';

class VibeScheduleApiService {
  Future<List<VibeSchedule>> getVibeSchedules(String venueId) async {
    final response = await http.get(
      Uri.parse('http://18.171.182.71/venues/$venueId/vibe-schedules'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VibeSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vibe schedules');
    }
  }
}
