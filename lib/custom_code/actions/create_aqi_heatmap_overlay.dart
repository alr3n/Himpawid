// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';
import 'get_location_and_air_quality.dart' show fetchAqiForCoordinates;

/// Builds a live, tile-based AQI color-wash layer for the heatmap page.
///
/// Unlike a single fixed image pinned near the user's location, this is a
/// real [TileLayer]: `flutter_map` asks it for whatever (x, y, z) tiles are
/// currently visible, and it renders each one on demand from real AQI
/// samples - so the wash covers the entire viewport, follows the user as
/// they pan/zoom (new tiles are requested automatically), and connects
/// seamlessly at tile edges because neighboring tiles draw from the same
/// shared, growing cache of real sample points rather than each computing
/// its own isolated data.
TileLayer buildAqiTileLayer() {
  final cache = _AqiSampleCache();
  return TileLayer(
    tileProvider: _AqiTileProvider(cache),
    tileDimension: _tileResolution,
    maxNativeZoom: 20,
    // Below this zoom, a single tile spans a huge area, which would need
    // dozens of real sample fetches to cover on first render - the color
    // wash simply doesn't render below this zoom (the base map still
    // does), rather than triggering a fetch storm if the user zooms out
    // a long way.
    minZoom: 10,
  );
}

const int _tileResolution = 256; // pixels, matches the base map tile size
const int _tileSubGrid = 16; // interpolated cells per tile axis
const int _washAlpha = 150; // ~59% opacity wash, matches the original design

class _AqiTileProvider extends TileProvider {
  _AqiTileProvider(this.cache);
  final _AqiSampleCache cache;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _AqiTileImage(coordinates, cache);
}

class _AqiTileImage extends ImageProvider<_AqiTileImage> {
  const _AqiTileImage(this.coordinates, this.cache);
  final TileCoordinates coordinates;
  final _AqiSampleCache cache;

  @override
  Future<_AqiTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
      _AqiTileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _render(decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _render(ImageDecoderCallback decode) async {
    final bytes = await _renderAqiTile(coordinates, cache);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is _AqiTileImage && other.coordinates == coordinates;

  @override
  int get hashCode => coordinates.hashCode;
}

/// Renders a single AQI tile: fetches (or reuses cached) real AQI samples
/// covering the tile's geographic area, then paints a smooth
/// inverse-distance-weighted color wash across it.
Future<Uint8List> _renderAqiTile(
    TileCoordinates coordinates, _AqiSampleCache cache) async {
  final bounds = _tileLatLngBounds(coordinates.x, coordinates.y, coordinates.z);
  await cache.ensureCoverage(bounds);

  final centerLat = (bounds.north + bounds.south) / 2;
  final centerLon = (bounds.east + bounds.west) / 2;
  final searchRadius =
      math.max(bounds.north - bounds.south, bounds.east - bounds.west) * 2 +
          _AqiSampleCache.gridSize * 2;
  final samples = cache.samplesNear(centerLat, centerLon, searchRadius);

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  const double cellSize = _tileResolution / _tileSubGrid;

  if (samples.isNotEmpty) {
    for (int gx = 0; gx < _tileSubGrid; gx++) {
      for (int gy = 0; gy < _tileSubGrid; gy++) {
        final lon = bounds.west +
            ((gx + 0.5) / _tileSubGrid) * (bounds.east - bounds.west);
        // Image y grows downward while latitude grows upward (north), so
        // row 0 (top of the tile) must map to the tile's north edge.
        final lat = bounds.north -
            ((gy + 0.5) / _tileSubGrid) * (bounds.north - bounds.south);

        final aqi = _interpolateAqi(lat, lon, samples);
        if (aqi <= 0) continue;
        final color = _getAQIColor(aqi).withAlpha(_washAlpha);

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
  }

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image =
      await picture.toImage(_tileResolution, _tileResolution);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List() ?? Uint8List(0);
}

/// Inverse-distance-weighted AQI estimate at [lat]/[lon] from the sampled
/// [points] - closer samples have more influence, giving a smooth blend
/// between sample points instead of hard boundaries. Because every tile
/// draws from the same shared [_AqiSampleCache], two adjacent tiles
/// evaluate the exact same function near their shared edge, which is what
/// makes them connect without a visible seam.
int _interpolateAqi(double lat, double lon, List<_AqiSample> points) {
  double weightedSum = 0.0;
  double weightSum = 0.0;

  for (final point in points) {
    final dLat = lat - point.lat;
    final dLon = lon - point.lon;
    final distSq = dLat * dLat + dLon * dLon;

    if (distSq < 1e-12) return point.aqi;

    final weight = 1.0 / distSq;
    weightedSum += weight * point.aqi;
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

class _LatLngBounds {
  const _LatLngBounds(this.north, this.south, this.east, this.west);
  final double north, south, east, west;
}

/// Standard slippy-map (Web Mercator) tile-to-lat/lng bounds conversion.
_LatLngBounds _tileLatLngBounds(int x, int y, int z) {
  final n = math.pow(2, z).toDouble();
  double latFromTileY(double ty) {
    final latRad = math.atan(_sinh(math.pi * (1 - 2 * ty / n)));
    return latRad * 180.0 / math.pi;
  }

  return _LatLngBounds(
    latFromTileY(y.toDouble()), // north
    latFromTileY((y + 1).toDouble()), // south
    (x + 1) / n * 360.0 - 180.0, // east
    x / n * 360.0 - 180.0, // west
  );
}

double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;

class _AqiSample {
  const _AqiSample(this.lat, this.lon, this.aqi);
  final double lat;
  final double lon;
  final int aqi;
}

/// A shared, growing cache of real AQI samples on a fixed geographic grid,
/// reused across every tile that's rendered during the map session. This is
/// what makes adjacent tiles blend seamlessly (they draw from the same
/// underlying sample set) and what keeps API usage bounded as the user
/// re-visits or zooms around an already-sampled area (a cached cell is
/// never re-fetched).
class _AqiSampleCache {
  static const double gridSize = 0.05; // degrees between real AQI samples

  final Map<String, int> _values = {};
  final Map<String, Future<void>> _pending = {};
  final _FetchThrottle _throttle = _FetchThrottle();

  String _keyFor(double glat, double glon) =>
      '${glat.toStringAsFixed(4)},${glon.toStringAsFixed(4)}';

  /// Ensures every real-sample grid cell covering [bounds], padded by one
  /// cell of margin so neighboring tiles share context, has been fetched at
  /// least once (cached cells resolve instantly; missing ones are fetched
  /// now and awaited).
  Future<void> ensureCoverage(_LatLngBounds bounds) async {
    final startLat =
        ((bounds.south - gridSize) / gridSize).floor() * gridSize;
    final endLat = ((bounds.north + gridSize) / gridSize).ceil() * gridSize;
    final startLon =
        ((bounds.west - gridSize) / gridSize).floor() * gridSize;
    final endLon = ((bounds.east + gridSize) / gridSize).ceil() * gridSize;

    final futures = <Future<void>>[];
    for (double lat = startLat; lat <= endLat; lat += gridSize) {
      for (double lon = startLon; lon <= endLon; lon += gridSize) {
        futures.add(_ensureCell(lat, lon));
      }
    }
    await Future.wait(futures);
  }

  Future<void> _ensureCell(double glat, double glon) {
    final key = _keyFor(glat, glon);
    if (_values.containsKey(key)) return Future.value();
    return _pending.putIfAbsent(key, () async {
      try {
        final aqi =
            await _throttle.run(() => fetchAqiForCoordinates(glat, glon));
        if (aqi > 0) _values[key] = aqi;
      } catch (e) {
        print('[AQI TILES] Sample fetch failed for ($glat, $glon): $e');
      } finally {
        _pending.remove(key);
      }
    });
  }

  /// Cached samples within [radius] degrees of ([lat], [lon]), for IDW
  /// interpolation.
  List<_AqiSample> samplesNear(double lat, double lon, double radius) {
    final result = <_AqiSample>[];
    _values.forEach((key, aqi) {
      final parts = key.split(',');
      final plat = double.parse(parts[0]);
      final plon = double.parse(parts[1]);
      if ((plat - lat).abs() <= radius && (plon - lon).abs() <= radius) {
        result.add(_AqiSample(plat, plon, aqi));
      }
    });
    return result;
  }
}

/// Caps how many AQI sample fetches run concurrently, so panning/zooming
/// quickly (which can bring many tiles into view at once, each needing
/// several sample cells) doesn't burst into dozens of simultaneous HTTP
/// requests against OpenWeather's rate limits.
class _FetchThrottle {
  static const int _maxConcurrent = 6;
  int _active = 0;
  final List<Completer<void>> _queue = [];

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= _maxConcurrent) {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      }
    }
  }
}
