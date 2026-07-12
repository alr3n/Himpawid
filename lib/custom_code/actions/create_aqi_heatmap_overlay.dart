// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' as latlong2;
import '/flutter_flow/flutter_flow_map.dart' show MapImageOverlay;
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Renders [aqiDataPoints] (each `{latitude, longitude, aqi}`) as a smooth
/// color wash across the area they were sampled from - interpolated between
/// the sampled points (inverse-distance weighting) rather than discrete
/// markers, so the entire visible area is tinted by how bad the air is
/// there. Rendered once as a single geo-bounded image (`MapImageOverlay`)
/// rather than Google Maps' per-tile `TileOverlay` scheme, since
/// `flutter_map`'s overlay layer works directly off lat/lng bounds.
///
/// Returns `null` if there's nothing to render (caller should show a
/// "no data yet" state, not fake coloring).
Future<MapImageOverlay?> createAQIHeatmapOverlay(
    List<Map<String, dynamic>> aqiDataPoints) async {
  if (aqiDataPoints.isEmpty) return null;

  const int resolution = 512; // pixels, square canvas
  const int gridSteps = 32; // sample cells per axis
  const double cellSize = resolution / gridSteps;
  const int washAlpha = 150; // ~59% opacity wash

  double minLat = double.infinity, maxLat = -double.infinity;
  double minLon = double.infinity, maxLon = -double.infinity;
  for (final p in aqiDataPoints) {
    final lat = p['latitude'] as double;
    final lon = p['longitude'] as double;
    if (lat < minLat) minLat = lat;
    if (lat > maxLat) maxLat = lat;
    if (lon < minLon) minLon = lon;
    if (lon > maxLon) maxLon = lon;
  }

  // Pad the sampled bounding box so the wash extends past the outermost
  // sample points (softening the edge via IDW extrapolation) instead of
  // cutting off sharply right at them - matches the grid spacing used in
  // fetch_heatmap_aqi.dart's sampling grid (0.03deg), so the rendered wash
  // is wide enough to cover what's actually visible on screen rather than
  // appearing as a small patch in the middle of the map.
  const double padding = 0.03;
  minLat -= padding;
  maxLat += padding;
  minLon -= padding;
  maxLon += padding;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  for (int gx = 0; gx < gridSteps; gx++) {
    for (int gy = 0; gy < gridSteps; gy++) {
      final lon = minLon + ((gx + 0.5) / gridSteps) * (maxLon - minLon);
      // Image y grows downward while latitude grows upward (north), so
      // row 0 (top of the image) must map to maxLat.
      final lat = maxLat - ((gy + 0.5) / gridSteps) * (maxLat - minLat);

      final aqi = _interpolateAqi(lat, lon, aqiDataPoints);
      final color = _getAQIColor(aqi).withAlpha(washAlpha);

      canvas.drawRect(
        ui.Rect.fromLTWH(
          gx * cellSize,
          gy * cellSize,
          cellSize + 1.0, // slight overlap avoids hairline seams
          cellSize + 1.0,
        ),
        ui.Paint()..color = color,
      );
    }
  }

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(resolution, resolution);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return null;

  return MapImageOverlay(
    bounds: LatLngBounds(
      latlong2.LatLng(maxLat, minLon), // north-west corner
      latlong2.LatLng(minLat, maxLon), // south-east corner
    ),
    image: MemoryImage(byteData.buffer.asUint8List()),
  );
}

/// Inverse-distance-weighted AQI estimate at [lat]/[lon] from the sampled
/// [points] - closer samples have more influence, giving a smooth blend
/// between grid points instead of hard boundaries.
int _interpolateAqi(
    double lat, double lon, List<Map<String, dynamic>> points) {
  double weightedSum = 0.0;
  double weightSum = 0.0;

  for (final point in points) {
    final plat = point['latitude'] as double;
    final plon = point['longitude'] as double;
    final paqi = (point['aqi'] as int).toDouble();

    final dLat = lat - plat;
    final dLon = lon - plon;
    final distSq = dLat * dLat + dLon * dLon;

    if (distSq < 1e-12) return paqi.round();

    final weight = 1.0 / distSq;
    weightedSum += weight * paqi;
    weightSum += weight;
  }

  return weightSum > 0 ? (weightedSum / weightSum).round() : 0;
}

ui.Color _getAQIColor(int aqi) {
  // AQI color mapping based on EPA standards
  if (aqi <= 50) {
    return const ui.Color(0xFF00E400); // Good
  } else if (aqi <= 100) {
    return const ui.Color(0xFFFFFF00); // Moderate
  } else if (aqi <= 150) {
    return const ui.Color(0xFFFF7E00); // Unhealthy for Sensitive Groups
  } else if (aqi <= 200) {
    return const ui.Color(0xFFFF0000); // Unhealthy
  } else if (aqi <= 300) {
    return const ui.Color(0xFF8F3F97); // Very Unhealthy
  } else {
    return const ui.Color(0xFF7E0023); // Hazardous
  }
}
