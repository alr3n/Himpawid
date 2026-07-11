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

/// Samples a 3x3 grid of points around the user's location and fetches the
/// real US EPA AQI (via OpenWeather PM2.5 data) for each, for rendering on
/// [createAQIHeatmapOverlay]'s heatmap tile overlay.
Future<List<Map<String, dynamic>>> fetchAQIHeatmapPoints() async {
  List<Map<String, dynamic>> heatmapPoints = [];

  try {
    final userLat = FFAppState().latitude;
    final userLng = FFAppState().longitude;

    if (userLat == 0.0 && userLng == 0.0) {
      // Fallback to default location if no user location
      return _generateSampleHeatmapPoints(37.7749, -122.4194);
    }

    // Generate grid of locations around user's position
    final locations = _generateLocationGrid(userLat, userLng);

    // Fetch real AQI data for each location
    for (final location in locations) {
      final aqi =
          await _fetchAQIFromAPI(location['latitude']!, location['longitude']!);
      if (aqi > 0) {
        heatmapPoints.add({
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'aqi': aqi,
        });
      }
      // Add small delay to avoid hitting API rate limits
      await Future.delayed(const Duration(milliseconds: 100));
    }
  } catch (e) {
    print('Error fetching AQI heatmap points: $e');
    // Return empty list on error
    return [];
  }

  return heatmapPoints;
}

List<Map<String, dynamic>> _generateSampleHeatmapPoints(
    double centerLat, double centerLng) {
  // Generate sample AQI data points around the center location
  List<Map<String, dynamic>> points = [];

  final sampleAQIData = [
    {'latitude': centerLat + 0.01, 'longitude': centerLng + 0.01, 'aqi': 25},
    {'latitude': centerLat - 0.005, 'longitude': centerLng + 0.008, 'aqi': 75},
    {'latitude': centerLat + 0.008, 'longitude': centerLng - 0.012, 'aqi': 125},
    {'latitude': centerLat - 0.012, 'longitude': centerLng - 0.005, 'aqi': 175},
    {'latitude': centerLat + 0.005, 'longitude': centerLng + 0.005, 'aqi': 45},
    {'latitude': centerLat - 0.008, 'longitude': centerLng + 0.003, 'aqi': 95},
    {'latitude': centerLat + 0.003, 'longitude': centerLng - 0.008, 'aqi': 135},
    {'latitude': centerLat - 0.003, 'longitude': centerLng - 0.010, 'aqi': 200},
    {
      'latitude': centerLat,
      'longitude': centerLng,
      'aqi': FFAppState().aqiValue
    },
  ];

  points.addAll(sampleAQIData);

  return points;
}

List<Map<String, double>> _generateLocationGrid(
    double centerLat, double centerLng) {
  // Generate a 3x3 grid of locations around the center point
  const double spacing = 0.01; // degrees
  List<Map<String, double>> locations = [];

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      locations.add({
        'latitude': centerLat + (i * spacing),
        'longitude': centerLng + (j * spacing),
      });
    }
  }

  return locations;
}

/// Fetches the current EPA AQI (0-500, higher = worse) for [lat]/[lon] from
/// OpenWeather, computed from PM2.5 via [epaAqiFromPm25] - the same
/// conversion used everywhere else in the app, so the heatmap colors and
/// the headline AQI number always agree.
Future<int> _fetchAQIFromAPI(double lat, double lon) async {
  try {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$kOpenWeatherApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final entries = data['list'] as List<dynamic>?;
      if (entries != null && entries.isNotEmpty) {
        final components = (entries.first as Map<String, dynamic>)['components']
                as Map<String, dynamic>? ??
            {};
        final pm25 = (components['pm2_5'] as num?)?.toDouble() ?? 0.0;
        return epaAqiFromPm25(pm25);
      }
    } else {
      print(
          'OpenWeather Air Pollution API error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error fetching AQI for location ($lat, $lon): $e');
  }

  return 0; // Return 0 on error
}
