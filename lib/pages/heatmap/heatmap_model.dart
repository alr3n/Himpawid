import '/flutter_flow/flutter_flow_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
import 'heatmap_widget.dart' show HeatmapWidget;
import 'package:flutter/material.dart';
import '/custom_code/actions/get_location_and_air_quality.dart'
    show fetchAqiForCoordinates;

class HeatmapModel extends FlutterFlowModel<HeatmapWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for the map widget.
  LatLng? mapCenter;
  final MapController mapController = MapController();
  // State field(s) for markers.
  List<FlutterFlowMarker> heatmapMarkers = [];
  List<FlutterFlowMarker> heatmapPointMarkers = [];
  // The AQI color-wash overlay, if any data has been fetched yet.
  MapImageOverlay? aqiOverlay;
  // Current time for clock
  DateTime currentTime = DateTime.now();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    // Dispose of controllers if needed
  }

  /// Fetches AQI across a grid centered on [centerLat]/[centerLng] (the
  /// user's location if omitted) and rebuilds the color-wash overlay from
  /// it - call again with the map's current camera center on pan/zoom to
  /// keep the coloring accurate to what's actually on screen.
  ///
  /// Returns the number of grid points that returned usable data, so the
  /// caller can distinguish "got real data" from "nothing came back" and
  /// show an accurate state instead of a silently blank map.
  Future<int> updateHeatmapData({double? centerLat, double? centerLng}) async {
    try {
      final aqiDataPoints = await actions.fetchAQIHeatmapPoints(
        centerLat: centerLat,
        centerLng: centerLng,
      );

      aqiOverlay = await actions.createAQIHeatmapOverlay(aqiDataPoints);

      return aqiDataPoints.length;
    } catch (e) {
      print('[HEATMAP] Error updating heatmap data: $e');
      rethrow;
    }
  }

  /// Fetches the EPA AQI (0-500, higher = worse) at an arbitrary map
  /// location, e.g. for a tap-to-query interaction.
  Future<int> getAQIAtLocation(double lat, double lon) =>
      fetchAqiForCoordinates(lat, lon);

  Color getAQIColor(int aqi) {
    if (aqi <= 50) {
      return const Color(0xFF00E400); // Good - Green
    } else if (aqi <= 100) {
      return const Color(0xFFFFFF00); // Moderate - Yellow
    } else if (aqi <= 150) {
      return const Color(0xFFFF7E00); // Unhealthy for Sensitive Groups - Orange
    } else if (aqi <= 200) {
      return const Color(0xFFFF0000); // Unhealthy - Red
    } else if (aqi <= 300) {
      return const Color(0xFF8F3F97); // Very Unhealthy - Purple
    } else {
      return const Color(0xFF7E0023); // Hazardous - Maroon
    }
  }




}
