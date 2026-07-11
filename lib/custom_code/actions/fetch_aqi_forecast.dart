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

/// Fetches the hourly AQI forecast from OpenWeather's Air Pollution API and
/// stores it in app state (chartX / chartY / avgLevel). Each hourly AQI
/// value is the US EPA index computed from that hour's forecast PM2.5
/// concentration, via [epaAqiFromPm25] — the same conversion used for the
/// current-conditions fetch, so the chart and the headline number agree.
///
/// [hours] is how many hours ahead to forecast (OpenWeather always returns
/// 96 hours of data; this just truncates to the requested window).
Future<bool> fetchAqiForecast(int hours) async {
  final double lat = FFAppState().latitude;
  final double lon = FFAppState().longitude;

  if (lat == 0.0 && lon == 0.0) {
    return false;
  }

  try {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=$lat&lon=$lon&appid=$kOpenWeatherApiKey');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      print(
          'OpenWeather AQI forecast error: ${response.statusCode} - ${response.body}');
      return false;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final forecasts = data['list'] as List<dynamic>?;
    if (forecasts == null || forecasts.isEmpty) {
      return false;
    }

    final requestedHours = hours.clamp(1, forecasts.length);
    final List<int> xValues = [];
    final List<int> yValues = [];

    for (var i = 0; i < requestedHours; i++) {
      final components =
          forecasts[i]['components'] as Map<String, dynamic>? ?? {};
      final pm25 = (components['pm2_5'] as num?)?.toDouble();
      if (pm25 == null) continue;
      xValues.add(i);
      yValues.add(epaAqiFromPm25(pm25));
    }

    if (yValues.isEmpty) {
      return false;
    }

    final avg =
        (yValues.reduce((a, b) => a + b) / yValues.length).round();

    FFAppState().update(() {
      FFAppState().chartX = xValues;
      FFAppState().chartY = yValues;
      FFAppState().avgLevel = avg;
      FFAppState().daysScale = hours;
    });

    return true;
  } catch (e) {
    print('Error fetching AQI forecast: $e');
    return false;
  }
}
