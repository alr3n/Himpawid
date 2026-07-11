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
    show kGoogleApiKey;

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

  Future<int> getAQIAtLocation(double lat, double lon) async {
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
          // Universal AQI is 0-100 (higher = cleaner). Convert to a
          // severity scale (higher = worse) for the legend colors.
          final int aqi = (uaqi['aqi'] as num?)?.toInt() ?? 0;
          if (aqi >= 80) return 25; // Excellent
          if (aqi >= 60) return 75; // Good
          if (aqi >= 40) return 125; // Moderate
          if (aqi >= 20) return 175; // Low
          return 250; // Poor
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
