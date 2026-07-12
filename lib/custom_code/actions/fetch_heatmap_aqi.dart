// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'get_location_and_air_quality.dart' show fetchAqiForCoordinates;

/// Samples a 5x5 grid of points around [centerLat]/[centerLng] (or the
/// user's current location if not given) and fetches the real US EPA AQI
/// for each, for rendering on [createAQIHeatmapOverlay]'s color-wash
/// overlay. The grid spans roughly the area visible on screen at the
/// map's default zoom, so panning around and re-calling this with the
/// new camera center keeps the coloring accurate to what's on screen
/// rather than freezing it to wherever the map first opened.
///
/// Returns an empty list (never fabricated placeholder data) if no
/// location is known yet or every fetch in the grid failed - callers
/// must render a "no data yet" state for that, not fake coloring.
Future<List<Map<String, dynamic>>> fetchAQIHeatmapPoints({
  double? centerLat,
  double? centerLng,
}) async {
  final userLat = centerLat ?? FFAppState().latitude;
  final userLng = centerLng ?? FFAppState().longitude;
  print('[HEATMAP] fetchAQIHeatmapPoints center=($userLat, $userLng)');

  if (userLat == 0.0 && userLng == 0.0) {
    print('[HEATMAP] No location available yet - returning no points '
        '(not fabricating sample data)');
    return [];
  }

  final locations = _generateLocationGrid(userLat, userLng);
  print('[HEATMAP] Fetching AQI for ${locations.length} grid points...');

  List<Map<String, dynamic>> heatmapPoints;
  try {
    final results = await Future.wait(locations.map((location) async {
      final aqi = await fetchAqiForCoordinates(
          location['latitude']!, location['longitude']!);
      return {
        'latitude': location['latitude'],
        'longitude': location['longitude'],
        'aqi': aqi,
      };
    }));

    heatmapPoints = results.where((p) => (p['aqi'] as int) > 0).toList();
  } catch (e) {
    print('[HEATMAP] Error fetching AQI heatmap points: $e');
    return [];
  }

  print('[HEATMAP] ${heatmapPoints.length}/${locations.length} grid points '
      'returned usable data');
  return heatmapPoints;
}

List<Map<String, double>> _generateLocationGrid(
    double centerLat, double centerLng) {
  // Generate a 5x5 grid of locations around the center point, ~3.3km
  // apart (roughly a 16km x 16km area) - wide enough that the rendered
  // color wash (see create_aqi_heatmap_overlay.dart) actually covers what's
  // visible at the map's default zoom level of 12, instead of leaving most
  // of the screen uncolored.
  const double spacing = 0.03; // degrees
  List<Map<String, double>> locations = [];

  for (int i = -2; i <= 2; i++) {
    for (int j = -2; j <= 2; j++) {
      locations.add({
        'latitude': centerLat + (i * spacing),
        'longitude': centerLng + (j * spacing),
      });
    }
  }

  return locations;
}
