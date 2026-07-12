// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'get_location_and_air_quality.dart'
    show kOpenWeatherApiKey, epaAqiFromPm25;

class AqiHistoryResult {
  const AqiHistoryResult({
    required this.xValues,
    required this.yValues,
    required this.dateLabels,
    required this.average,
    required this.minAqi,
    required this.maxAqi,
  });

  final List<int> xValues;
  final List<int> yValues;
  final List<String> dateLabels;
  final int average;
  final int minAqi;
  final int maxAqi;
}

/// Fetches [days] worth of historical air quality for the user's current
/// location from OpenWeather's Air Pollution History API and aggregates
/// the hourly readings into one EPA AQI value per day (via
/// [epaAqiFromPm25]), for a weekly/monthly trend chart.
///
/// Returns `null` if the location isn't known yet or the request fails.
Future<AqiHistoryResult?> fetchAqiHistory(int days) async {
  final lat = FFAppState().latitude;
  final lon = FFAppState().longitude;
  if (lat == 0.0 && lon == 0.0) return null;

  final end = DateTime.now().toUtc();
  final start = end.subtract(Duration(days: days));

  try {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution/history'
        '?lat=$lat&lon=$lon'
        '&start=${start.millisecondsSinceEpoch ~/ 1000}'
        '&end=${end.millisecondsSinceEpoch ~/ 1000}'
        '&appid=$kOpenWeatherApiKey');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      print(
          'OpenWeather AQI history error: ${response.statusCode} - ${response.body}');
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final entries = data['list'] as List<dynamic>?;
    if (entries == null || entries.isEmpty) return null;

    // Bucket hourly readings by calendar day (epoch day, so it sorts
    // correctly regardless of month/year boundaries), then average PM2.5
    // per day before converting to an EPA AQI.
    final Map<int, List<double>> byDay = {};
    for (final e in entries) {
      final entry = e as Map<String, dynamic>;
      final dt = (entry['dt'] as num).toInt();
      final epochDay = dt ~/ 86400;
      final components = entry['components'] as Map<String, dynamic>? ?? {};
      final pm25 = (components['pm2_5'] as num?)?.toDouble();
      if (pm25 == null) continue;
      byDay.putIfAbsent(epochDay, () => []).add(pm25);
    }

    if (byDay.isEmpty) return null;

    final sortedDays = byDay.keys.toList()..sort();
    final xValues = <int>[];
    final yValues = <int>[];
    final dateLabels = <String>[];

    for (var i = 0; i < sortedDays.length; i++) {
      final pm25Readings = byDay[sortedDays[i]]!;
      final avgPm25 =
          pm25Readings.reduce((a, b) => a + b) / pm25Readings.length;
      final aqi = epaAqiFromPm25(avgPm25);
      xValues.add(i);
      yValues.add(aqi);
      final date = DateTime.fromMillisecondsSinceEpoch(
          sortedDays[i] * 86400 * 1000,
          isUtc: true);
      dateLabels.add(DateFormat('MMM d').format(date));
    }

    final average = (yValues.reduce((a, b) => a + b) / yValues.length).round();
    final minAqi = yValues.reduce((a, b) => a < b ? a : b);
    final maxAqi = yValues.reduce((a, b) => a > b ? a : b);

    return AqiHistoryResult(
      xValues: xValues,
      yValues: yValues,
      dateLabels: dateLabels,
      average: average,
      minAqi: minAqi,
      maxAqi: maxAqi,
    );
  } catch (e) {
    print('Error fetching AQI history: $e');
    return null;
  }
}
