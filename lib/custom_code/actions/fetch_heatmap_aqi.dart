// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import 'get_location_and_air_quality.dart' show kGoogleApiKey;

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

Future<int> _fetchAQIFromAPI(double lat, double lon) async {
  try {
    final aqiUrl = Uri.parse(
        'https://airquality.googleapis.com/v1/currentConditions:lookup?key=$kGoogleApiKey');
    final response = await http.post(
      aqiUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'location': {'latitude': lat, 'longitude': lon},
        'universalAqi': true,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final indexes = data['indexes'] as List<dynamic>?;
      if (indexes != null && indexes.isNotEmpty) {
        final uaqi = indexes.firstWhere(
          (i) => i['code'] == 'uaqi',
          orElse: () => indexes.first,
        );
        // Universal AQI is 0-100 where higher = cleaner air.
        // Convert to a pollution-severity scale (higher = worse) so the
        // existing legend/color logic keeps working.
        final int aqi = (uaqi['aqi'] as num?)?.toInt() ?? 0;
        if (aqi >= 80) return 25; // Excellent -> Good
        if (aqi >= 60) return 75; // Good -> Moderate
        if (aqi >= 40) return 125; // Moderate -> Unhealthy (sensitive)
        if (aqi >= 20) return 175; // Low -> Unhealthy
        return 225; // Poor -> Very Unhealthy
      }
    } else {
      print(
          'Google Air Quality API error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error fetching AQI for location ($lat, $lon): $e');
  }

  return 0; // Return 0 on error
}

double _calculateHeatmapWeight(int aqi) {
  // Convert AQI to heatmap weight (0.0 to 1.0)
  if (aqi <= 50) {
    return 0.3 + (aqi / 50.0) * 0.2; // 0.3 to 0.5
  } else if (aqi <= 100) {
    return 0.5 + ((aqi - 50) / 50.0) * 0.2; // 0.5 to 0.7
  } else if (aqi <= 150) {
    return 0.7 + ((aqi - 100) / 50.0) * 0.15; // 0.7 to 0.85
  } else {
    return 0.85 + ((aqi - 150) / 100.0) * 0.15; // 0.85 to 1.0
  }
}

/// Google Air Quality heatmap tiles rendered directly on the map.
Future<gmaps.TileOverlay> fetchHeatmapTileOverlay() async {
  final tileOverlay = gmaps.TileOverlay(
    tileOverlayId: const gmaps.TileOverlayId('google_aqi_heatmap'),
    tileProvider: _GoogleAqiTileProvider(),
    transparency: 0.25,
  );

  return tileOverlay;
}

class _GoogleAqiTileProvider extends gmaps.TileProvider {
  @override
  Future<gmaps.Tile> getTile(int x, int y, int? zoom) async {
    try {
      final url = Uri.parse(
          'https://airquality.googleapis.com/v1/mapTypes/UAQI_INDIGO_PERSIAN/heatmapTiles/$zoom/$x/$y?key=$kGoogleApiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return gmaps.Tile(256, 256, response.bodyBytes);
      }
    } catch (e) {
      print('Error fetching AQI heatmap tile ($zoom/$x/$y): $e');
    }
    return gmaps.Tile(256, 256, Uint8List(0));
  }
}
