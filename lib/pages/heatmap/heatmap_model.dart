import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
import 'heatmap_widget.dart' show HeatmapWidget;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/custom_code/actions/get_location_and_air_quality.dart'
    show kOpenWeatherApiKey, epaAqiFromPm25;

class HeatmapModel extends FlutterFlowModel<HeatmapWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  late Completer<GoogleMapController> googleMapsController;
  // State field(s) for markers.
  List<FlutterFlowMarker> heatmapMarkers = [];
  List<FlutterFlowMarker> heatmapPointMarkers = [];
  // State field(s) for tile overlays.
  Set<TileOverlay> tileOverlays = {};
  // Current time for clock
  DateTime currentTime = DateTime.now();

  @override
  void initState(BuildContext context) {
    googleMapsController = Completer<GoogleMapController>();
  }

  @override
  void dispose() {
    // Dispose of controllers if needed
  }

  Future<void> updateHeatmapData() async {
    try {
      // Fetch AQI data points
      final aqiDataPoints = await actions.fetchAQIHeatmapPoints();

      // Create tile overlay
      final tileOverlay = await actions.createAQIHeatmapOverlay(aqiDataPoints);

      // Update tile overlays
      tileOverlays = {tileOverlay};
    } catch (e) {
      print('Error updating heatmap data: $e');
    }
  }

  /// Fetches the EPA AQI (0-500, higher = worse) at an arbitrary map
  /// location, e.g. for a tap-to-query interaction.
  Future<int> getAQIAtLocation(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$kOpenWeatherApiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final entries = data['list'] as List<dynamic>?;
        if (entries != null && entries.isNotEmpty) {
          final components =
              (entries.first as Map<String, dynamic>)['components']
                      as Map<String, dynamic>? ??
                  {};
          final pm25 = (components['pm2_5'] as num?)?.toDouble() ?? 0.0;
          return epaAqiFromPm25(pm25);
        }
      }
    } catch (e) {
      print('Error getting AQI: $e');
    }
    return 0;
  }

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
