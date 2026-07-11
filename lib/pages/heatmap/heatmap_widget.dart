import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'heatmap_model.dart';
export 'heatmap_model.dart';

/// Air quality map (full-bleed dark map with floating chips)
class HeatmapWidget extends StatefulWidget {
  const HeatmapWidget({super.key});

  static String routeName = 'heatmap';
  static String routePath = '/heatmap';

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  late HeatmapModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeatmapModel());

    // Initialize with user's location
    _initializeUserLocation();
  }

  Future<void> _initializeUserLocation() async {
    // Get user's location
    await actions.getLocationAndAirQuality();

    if (FFAppState().latitude != 0.0 && FFAppState().longitude != 0.0) {
      setState(() {
        _model.googleMapsCenter =
            LatLng(FFAppState().latitude, FFAppState().longitude);
      });

      // Animate camera to user's location
      final gmaps.GoogleMapController controller =
          await _model.googleMapsController.future;
      controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(FFAppState().latitude, FFAppState().longitude), 12.0),
      );

      // Render the AQI heatmap overlay (colored by real EPA AQI values).
      await _updateHeatmapData();
    }
  }

  Future<void> _updateHeatmapData() async {
    await _model.updateHeatmapData();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _legendDot(String label, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.slateDeep,
        body: Stack(
          children: [
            // ---------- Full-bleed map ----------
            Positioned.fill(
              child: FlutterFlowGoogleMap(
                controller: _model.googleMapsController,
                onCameraIdle: (latLng) {
                  _model.googleMapsCenter = latLng;
                },
                initialLocation: _model.googleMapsCenter ??= LatLng(
                    FFAppState().latitude != 0.0
                        ? FFAppState().latitude
                        : 37.7749,
                    FFAppState().longitude != 0.0
                        ? FFAppState().longitude
                        : -122.4194),
                markers: [
                  ..._model.heatmapMarkers,
                  ..._model.heatmapPointMarkers
                ],
                markerColor: GoogleMarkerColor.green,
                mapType: MapType.normal,
                style: GoogleMapStyle.airQuality,
                initialZoom: 12.0,
                allowInteraction: true,
                allowZoom: true,
                showZoomControls: false,
                showLocation: true,
                showCompass: false,
                showMapToolbar: false,
                showTraffic: false,
                centerMapOnMarkerTap: true,
                tileOverlays: _model.tileOverlays,
              ),
            ),

            // ---------- Floating header ----------
            SafeArea(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location pill
                    Container(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 18.0, 6.0),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10.0,
                            color: Color(0x33000000),
                            offset: Offset(0.0, 4.0),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(HomePageWidget.routeName);
                            },
                            child: Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: theme.slateDeep,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: theme.lime,
                                size: 18.0,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                FFAppState().currentLocation.isNotEmpty
                                    ? FFAppState().currentLocation
                                    : 'Locating...',
                                style: GoogleFonts.manrope(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w800,
                                  color: theme.primaryText,
                                ),
                              ),
                              Text(
                                'Air quality map',
                                style: GoogleFonts.manrope(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w500,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // My-location button
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await _initializeUserLocation();
                      },
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 4.0),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: theme.slateDeep,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Brand chip ----------
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional(0.0, -0.75),
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(18.0, 8.0, 18.0, 8.0),
                  decoration: BoxDecoration(
                    color: theme.lime,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Color(0x33000000),
                        offset: Offset(0.0, 4.0),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.air_rounded,
                        color: theme.raisinBlack,
                        size: 18.0,
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        'himpawid',
                        style: GoogleFonts.manrope(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          color: theme.raisinBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Floating legend ----------
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 4.0),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _legendDot('Good', const Color(0xFF00E400)),
                        SizedBox(width: 12.0),
                        _legendDot('Moderate', const Color(0xFFFFFF00)),
                        SizedBox(width: 12.0),
                        _legendDot('Unhealthy', const Color(0xFFFF0000)),
                        SizedBox(width: 12.0),
                        _legendDot('Hazardous', const Color(0xFF7E0023)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
