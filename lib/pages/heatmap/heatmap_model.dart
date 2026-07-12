import '/flutter_flow/flutter_flow_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
import 'heatmap_widget.dart' show HeatmapWidget;
import 'package:flutter/material.dart';

class HeatmapModel extends FlutterFlowModel<HeatmapWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for the map widget.
  LatLng? mapCenter;
  final MapController mapController = MapController();
  // State field(s) for markers.
  List<FlutterFlowMarker> heatmapMarkers = [];
  List<FlutterFlowMarker> heatmapPointMarkers = [];
  // Live, tile-based AQI color-wash layer - created once and reused so its
  // internal sample cache persists across pans/zooms for the page's whole
  // lifetime instead of being rebuilt (and losing its cache) on every
  // camera move.
  late final Widget aqiTileLayer;
  // Current time for clock
  DateTime currentTime = DateTime.now();

  @override
  void initState(BuildContext context) {
    aqiTileLayer = actions.buildAqiTileLayer();
  }

  @override
  void dispose() {
    // Dispose of controllers if needed
  }
}
