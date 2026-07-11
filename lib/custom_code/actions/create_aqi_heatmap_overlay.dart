// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';

Future<gmaps.TileOverlay> createAQIHeatmapOverlay(List<Map<String, dynamic>> aqiDataPoints) async {
  // Create custom tile provider for AQI heatmap
  final tileProvider = _AQITileProvider(aqiDataPoints);

  // Create tile overlay
  final tileOverlay = gmaps.TileOverlay(
    tileOverlayId: const gmaps.TileOverlayId('aqi_heatmap'),
    tileProvider: tileProvider,
    transparency: 0.4, // Adjust transparency for overlay effect
  );

  return tileOverlay;
}

class _AQITileProvider extends gmaps.TileProvider {
  final List<Map<String, dynamic>> aqiDataPoints;

  _AQITileProvider(this.aqiDataPoints);

  @override
  Future<gmaps.Tile> getTile(int x, int y, int? zoom) async {
    try {
      // Create a 256x256 image for the tile
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      final ui.Size size = ui.Size(256.0, 256.0);

      // Fill with transparent background
      final ui.Paint backgroundPaint = ui.Paint()..color = ui.Color(0x00000000);
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

      // Convert tile coordinates to lat/lng bounds
      final bounds = _getTileBounds(x, y, zoom!);

      // Draw heatmap points within this tile
      for (final point in aqiDataPoints) {
        final lat = point['latitude'] as double;
        final lng = point['longitude'] as double;
        final aqi = point['aqi'] as int;

        // Check if point is within tile bounds
        if (lat >= bounds['south']! && lat <= bounds['north']! &&
            lng >= bounds['west']! && lng <= bounds['east']!) {

          // Convert lat/lng to pixel coordinates within tile
          final pixelX = _lngToPixel(lng, zoom) - _lngToPixel(bounds['west']!, zoom);
          final pixelY = _latToPixel(lat, zoom) - _latToPixel(bounds['north']!, zoom);

          // Get color based on AQI value
          final color = _getAQIColor(aqi);

          // Draw heatmap point
          final ui.Paint paint = ui.Paint()
            ..color = color
            ..style = ui.PaintingStyle.fill;

          // Draw circle with radius based on zoom level
          final radius = math.max(5.0, 20.0 / math.pow(2, zoom - 10));
          canvas.drawCircle(ui.Offset(pixelX, pixelY), radius, paint);
        }
      }

      // Convert canvas to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return gmaps.Tile(256, 256, byteData.buffer.asUint8List());
      } else {
        return gmaps.Tile(256, 256, Uint8List(0));
      }
    } catch (e) {
      // Return transparent tile on error
      return gmaps.Tile(256, 256, Uint8List(0));
    }
  }

  Map<String, double> _getTileBounds(int x, int y, int zoom) {
    final n = math.pow(2, zoom);
    final lonMin = x / n * 360.0 - 180.0;
    final latRadMin = math.atan((math.exp(math.pi * (1 - 2 * y / n)) - math.exp(-math.pi * (1 - 2 * y / n))) / 2);
    final latMin = latRadMin * 180.0 / math.pi;

    final lonMax = (x + 1) / n * 360.0 - 180.0;
    final latRadMax = math.atan((math.exp(math.pi * (1 - 2 * (y + 1) / n)) - math.exp(-math.pi * (1 - 2 * (y + 1) / n))) / 2);
    final latMax = latRadMax * 180.0 / math.pi;

    return {
      'north': latMax,
      'south': latMin,
      'east': lonMax,
      'west': lonMin,
    };
  }

  double _latToPixel(double lat, int zoom) {
    final latRad = lat * math.pi / 180.0;
    return (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 * 256 * math.pow(2, zoom);
  }

  double _lngToPixel(double lng, int zoom) {
    return (lng + 180.0) / 360.0 * 256 * math.pow(2, zoom);
  }

  ui.Color _getAQIColor(int aqi) {
    // AQI color mapping based on EPA standards
    if (aqi <= 50) {
      // Good - Green
      return ui.Color(0xFF00E400);
    } else if (aqi <= 100) {
      // Moderate - Yellow
      return ui.Color(0xFFFFFF00);
    } else if (aqi <= 150) {
      // Unhealthy for Sensitive Groups - Orange
      return ui.Color(0xFFFF7E00);
    } else if (aqi <= 200) {
      // Unhealthy - Red
      return ui.Color(0xFFFF0000);
    } else if (aqi <= 300) {
      // Very Unhealthy - Purple
      return ui.Color(0xFF8F3F97);
    } else {
      // Hazardous - Maroon
      return ui.Color(0xFF7E0023);
    }
  }
}
