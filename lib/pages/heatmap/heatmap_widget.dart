import '/flutter_flow/flutter_flow_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/actions/get_location_and_air_quality.dart'
    show epaCategory;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:latlong2/latlong.dart' as latlong;
import 'heatmap_model.dart';
export 'heatmap_model.dart';

/// Air quality map (full-bleed live map, colored by AQI, with a bottom
/// summary card)
class HeatmapWidget extends StatefulWidget {
  const HeatmapWidget({super.key});

  static String routeName = 'heatmap';
  static String routePath = '/heatmap';

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

enum _HeatmapStatus { loading, ready, empty, error }

class _HeatmapWidgetState extends State<HeatmapWidget> {
  late HeatmapModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _panRefreshDebounce;
  LatLng? _lastFetchedCenter;
  _HeatmapStatus _heatmapStatus = _HeatmapStatus.loading;

  // Bottom summary card state for wherever the map is currently centered.
  // Null means "show the device's own current location" (the initial
  // state, from FFAppState) - once the user pans, these track the
  // panned-to location's real AQI/name in real time instead of staying
  // frozen on the device's location.
  int? _panAqi;
  String? _panLocationName;
  bool _panSummaryLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeatmapModel());

    // Initialize with user's location
    _initializeUserLocation();
  }

  Future<void> _initializeUserLocation() async {
    setState(() {
      _panAqi = null;
      _panLocationName = null;
    });

    // Get user's location
    await actions.getLocationAndAirQuality();
    if (mounted) setState(() {});

    if (FFAppState().latitude != 0.0 && FFAppState().longitude != 0.0) {
      setState(() {
        _model.mapCenter =
            LatLng(FFAppState().latitude, FFAppState().longitude);
      });

      // Move camera to user's location
      _model.mapController.move(
        latlong.LatLng(FFAppState().latitude, FFAppState().longitude),
        12.0,
      );

      // Render the AQI heatmap overlay (colored by real EPA AQI values).
      await _updateHeatmapData(
        centerLat: FFAppState().latitude,
        centerLng: FFAppState().longitude,
      );
    }
  }

  Future<void> _updateHeatmapData({double? centerLat, double? centerLng}) async {
    if (mounted) setState(() => _heatmapStatus = _HeatmapStatus.loading);
    try {
      final pointCount = await _model.updateHeatmapData(
        centerLat: centerLat,
        centerLng: centerLng,
      );
      if (centerLat != null && centerLng != null) {
        _lastFetchedCenter = LatLng(centerLat, centerLng);
      }
      if (mounted) {
        setState(() {
          _heatmapStatus =
              pointCount > 0 ? _HeatmapStatus.ready : _HeatmapStatus.empty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _heatmapStatus = _HeatmapStatus.error);
    }
  }

  /// Called when the map settles after a pan/zoom. Re-fetches AQI for the
  /// newly-visible area (debounced, and only if the camera actually moved
  /// a meaningful distance from where we last fetched) so the coloring
  /// tracks wherever the user is currently looking, not just where the
  /// map first opened.
  void _onCameraIdle(LatLng latLng) {
    _model.mapCenter = latLng;

    final last = _lastFetchedCenter;
    if (last != null) {
      final movedFar = (latLng.latitude - last.latitude).abs() > 0.01 ||
          (latLng.longitude - last.longitude).abs() > 0.01;
      if (!movedFar) return;
    }

    _panRefreshDebounce?.cancel();
    _panRefreshDebounce = Timer(const Duration(milliseconds: 500), () {
      _updateHeatmapData(
        centerLat: latLng.latitude,
        centerLng: latLng.longitude,
      );
      _updatePanSummary(latLng);
    });
  }

  /// Fetches the real AQI and place name for wherever the map is now
  /// centered, so the bottom summary card reflects the panned-to location
  /// in real time instead of staying frozen on the device's own location.
  Future<void> _updatePanSummary(LatLng latLng) async {
    if (mounted) setState(() => _panSummaryLoading = true);
    try {
      final results = await Future.wait([
        actions.fetchAqiForCoordinates(latLng.latitude, latLng.longitude),
        actions.reverseGeocodeCityName(latLng.latitude, latLng.longitude),
      ]);
      if (mounted) {
        setState(() {
          _panAqi = results[0] as int;
          _panLocationName = results[1] as String;
          _panSummaryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _panSummaryLoading = false);
    }
  }

  @override
  void dispose() {
    _panRefreshDebounce?.cancel();
    _model.dispose();

    super.dispose();
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
              child: FlutterFlowMap(
                controller: _model.mapController,
                onCameraIdle: _onCameraIdle,
                initialLocation: _model.mapCenter ??= LatLng(
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
                markerColor: MapMarkerColor.green,
                style: MapTileStyle.aqiLive,
                initialZoom: 12.0,
                allowInteraction: true,
                allowZoom: true,
                showLocation: true,
                centerMapOnMarkerTap: true,
                imageOverlay: _model.aqiOverlay,
              ),
            ),

            // ---------- Floating header ----------
            SafeArea(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        width: 40.0,
                        height: 40.0,
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
                          Icons.arrow_back_rounded,
                          color: theme.slateDeep,
                          size: 20.0,
                        ),
                      ),
                    ),
                    // LIVE badge
                    Container(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(14.0, 7.0, 14.0, 7.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F6FED),
                        borderRadius: BorderRadius.circular(20.0),
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
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            'LIVE',
                            style: GoogleFonts.manrope(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
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
                        width: 40.0,
                        height: 40.0,
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
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Heatmap status banner ----------
            if (_heatmapStatus != _HeatmapStatus.ready)
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional(0.0, -0.62),
                  child: _heatmapStatusBanner(context),
                ),
              ),

            // ---------- Bottom AQI summary card ----------
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                  child: _bottomSummaryCard(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heatmapStatusBanner(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    late final IconData icon;
    late final String message;
    final bool showRetry;
    final bool showSpinner;

    switch (_heatmapStatus) {
      case _HeatmapStatus.loading:
        icon = Icons.hourglass_top_rounded;
        message = 'Fetching air quality across the map...';
        showRetry = false;
        showSpinner = true;
        break;
      case _HeatmapStatus.empty:
        icon = Icons.info_outline_rounded;
        message = FFAppState().latitude == 0.0 && FFAppState().longitude == 0.0
            ? 'Waiting for your location...'
            : 'No air quality data available for this area.';
        showRetry = true;
        showSpinner = false;
        break;
      case _HeatmapStatus.error:
        icon = Icons.error_outline_rounded;
        message = 'Couldn\'t load air quality data.';
        showRetry = true;
        showSpinner = false;
        break;
      case _HeatmapStatus.ready:
        return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      padding: EdgeInsetsDirectional.fromSTEB(14.0, 10.0, 14.0, 10.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18.0),
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
          if (showSpinner)
            SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: theme.lime,
              ),
            )
          else
            Icon(icon, color: theme.secondaryText, size: 16.0),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          if (showRetry) ...[
            SizedBox(width: 8.0),
            InkWell(
              onTap: _initializeUserLocation,
              child: Text(
                'Retry',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: theme.lime,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomSummaryCard(BuildContext context) {
    final aqi = _panAqi ?? FFAppState().aqiValue;
    final category =
        aqi > 0 ? epaCategory(aqi) : 'Fetching air quality...';
    final rawCity = _panLocationName ?? FFAppState().currentLocation;
    final city = rawCity.isNotEmpty ? rawCity : 'Locating...';

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 16.0,
            color: Color(0x4D000000),
            offset: Offset(0.0, 8.0),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14.0, color: const Color(0xFF8A94A6)),
                    SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A94A6),
                        ),
                      ),
                    ),
                    if (_panSummaryLoading) ...[
                      SizedBox(width: 6.0),
                      SizedBox(
                        width: 10.0,
                        height: 10.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: const Color(0xFF8A94A6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(HomePageWidget.routeName);
                },
                child: Icon(Icons.close_rounded,
                    color: const Color(0xFF8A94A6), size: 20.0),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          _aqiArcGauge(context, aqi),
          SizedBox(height: 6.0),
          Text(
            category,
            style: GoogleFonts.manrope(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 10.0),
          Container(height: 1.0, color: const Color(0xFFE8EAED)),
          SizedBox(height: 10.0),
          Text(
            'Dominant Pollutant · PM2.5',
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A94A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aqiArcGauge(BuildContext context, int aqi) {
    return SizedBox(
      width: 160.0,
      height: 86.0,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(160.0, 82.0),
            painter: _AqiArcGaugePainter(aqi),
          ),
          Positioned(
            bottom: 18.0,
            child: Text(
              aqi > 0 ? '$aqi' : '--',
              style: GoogleFonts.manrope(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
                height: 1.0,
              ),
            ),
          ),
          Positioned(
            left: 2.0,
            bottom: 0.0,
            child: Text(
              '0',
              style: GoogleFonts.manrope(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A94A6),
              ),
            ),
          ),
          Positioned(
            right: 2.0,
            bottom: 0.0,
            child: Text(
              '500',
              style: GoogleFonts.manrope(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A94A6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the semi-circular AQI gauge: a rainbow arc across the EPA
/// breakpoints (0-500, green through maroon) with a pointer marking the
/// current [aqi] value along that arc.
class _AqiArcGaugePainter extends CustomPainter {
  const _AqiArcGaugePainter(this.aqi);

  final int aqi;

  static const List<(int, int, Color)> _bands = [
    (0, 50, Color(0xFF00E400)),
    (50, 100, Color(0xFFFFFF00)),
    (100, 150, Color(0xFFFF7E00)),
    (150, 200, Color(0xFFFF0000)),
    (200, 300, Color(0xFF8F3F97)),
    (300, 500, Color(0xFF7E0023)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10.0;
    const startAngle = math.pi; // left side (180deg)
    const totalSweep = math.pi; // half circle to the right side

    for (final band in _bands) {
      final bandStart = startAngle + (band.$1 / 500) * totalSweep;
      final bandSweep = ((band.$2 - band.$1) / 500) * totalSweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        bandStart,
        bandSweep,
        false,
        Paint()
          ..color = band.$3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9.0
          ..strokeCap = StrokeCap.butt,
      );
    }

    if (aqi > 0) {
      final clamped = aqi.clamp(0, 500);
      final pointerAngle = startAngle + (clamped / 500) * totalSweep;
      final pointerPos = Offset(
        center.dx + radius * math.cos(pointerAngle),
        center.dy + radius * math.sin(pointerAngle),
      );
      canvas.drawCircle(pointerPos, 7.0, Paint()..color = Colors.white);
      canvas.drawCircle(
        pointerPos,
        7.0,
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AqiArcGaugePainter oldDelegate) =>
      oldDelegate.aqi != aqi;
}
