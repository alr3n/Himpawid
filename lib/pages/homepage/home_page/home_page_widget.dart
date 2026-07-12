import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/homepage/blogs/article_card1/article_card1_widget.dart';
import '/pages/homepage/blogs/article_card2/article_card2_widget.dart';
import '/pages/homepage/chart_card/chart_card_widget.dart';
import '/pages/homepage/navigation/navigation_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/actions/get_location_and_air_quality.dart'
    show epaColor;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class _DashboardFeature {
  const _DashboardFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.previewBuilder,
  });

  final IconData icon;
  final String title;
  final String description;
  final void Function(BuildContext context) onTap;
  final Widget Function(BuildContext context) previewBuilder;
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _notificationTimer; // Timer for periodic notifications

  final animationsMap = <String, AnimationInfo>{};

  // ---------- Explore card preview state ----------
  final Completer<GoogleMapController> _previewMapController = Completer();
  List<actions.CityAqi>? _topRankings;
  List<Map<String, dynamic>> _previewFavourites = [];
  final Map<String, int> _favouriteAqi = {};
  actions.AqiHistoryResult? _weekHistory;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.getLocationAndAirQuality();
      await actions.fetchAqiForecast(12);
      if (mounted) safeSetState(() {});
      await _initializeFCM();
      _loadExplorePreviews();
    });

    // Start periodic notification generation every 3 minutes
    _notificationTimer = Timer.periodic(Duration(minutes: 3), (timer) async {
      await actions.generateNotification();
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, 14.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 250.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: Offset(10.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'articleCard1OnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 75.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 75.0.ms,
            duration: 400.0.ms,
            begin: Offset(10.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 75.0.ms,
            duration: 200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
  }

  /// Kicks off the data each Explore card preview needs, independently -
  /// each populates and updates its own card as soon as it's ready rather
  /// than all waiting on the slowest one.
  void _loadExplorePreviews() {
    // Favourites: read from the user's doc, then fetch AQI per saved spot.
    final rawFavourites = currentUserDocument?.favouriteLocations ?? [];
    _previewFavourites = rawFavourites
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
    for (final fav in _previewFavourites) {
      final lat = (fav['latitude'] as num).toDouble();
      final lon = (fav['longitude'] as num).toDouble();
      actions.fetchAqiForCoordinates(lat, lon).then((aqi) {
        if (mounted) setState(() => _favouriteAqi[fav['name'] as String] = aqi);
      });
    }
    if (mounted) setState(() {});

    // Ranking: worst cities, worldwide.
    actions.fetchCityRankings().then((result) {
      if (mounted) setState(() => _topRankings = result);
    });

    // Historical: this week's trend.
    actions.fetchAqiHistory(7).then((result) {
      if (mounted) setState(() => _weekHistory = result);
    });
  }

  Future<void> _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token
      String? token = await messaging.getToken();

      if (token != null) {
        // Save token to Firestore for current user
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  TextStyle _manrope(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? FlutterFlowTheme.of(context).primaryText,
      height: height,
    );
  }

  Widget _healthRecommendationCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final category = FFAppState().healthRisk;
    final aqi = FFAppState().aqiValue;
    final (icon, message) = _recommendationFor(category);
    final accent = aqi > 0 ? epaColor(aqi) : theme.lime;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22.0),
          ),
          SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.isNotEmpty ? category : 'Air quality update',
                  style: _manrope(context, size: 15.0, weight: FontWeight.w800),
                ),
                SizedBox(height: 4.0),
                Text(
                  message,
                  style: _manrope(context,
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: theme.secondaryText,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _recommendationFor(String category) {
    switch (category) {
      case 'Good':
        return (
          Icons.check_circle_outline_rounded,
          'Air quality is great today. It\'s a good time for outdoor '
              'activities.'
        );
      case 'Moderate':
        return (
          Icons.info_outline_rounded,
          'Air quality is acceptable. Unusually sensitive individuals '
              'should consider limiting prolonged outdoor exertion.'
        );
      case 'Unhealthy for Sensitive Groups':
        return (
          Icons.warning_amber_rounded,
          'Sensitive groups - children, older adults, and those with '
              'asthma or heart conditions - should reduce prolonged '
              'outdoor exertion today.'
        );
      case 'Unhealthy':
        return (
          Icons.masks_outlined,
          'Everyone may begin to experience health effects. Consider '
              'wearing a mask outdoors and limiting strenuous activity.'
        );
      case 'Very Unhealthy':
        return (
          Icons.report_problem_rounded,
          'Health alert: everyone is more likely to be affected. Avoid '
              'prolonged outdoor exertion.'
        );
      case 'Hazardous':
        return (
          Icons.dangerous_rounded,
          'Health emergency. Avoid all outdoor activity and stay indoors '
              'with air purification if possible.'
        );
      default:
        return (
          Icons.hourglass_top_rounded,
          'Fetching today\'s air quality guidance...'
        );
    }
  }

  late final List<_DashboardFeature> _dashboardFeatures = [
    _DashboardFeature(
      icon: Icons.map_rounded,
      title: 'View Your Area\'s Air Quality Conditions on Map',
      description: 'Check air quality condition in your area with '
          'interactive maps for better understanding.',
      onTap: (context) => context.pushNamed(HeatmapWidget.routeName),
      previewBuilder: _mapPreview,
    ),
    _DashboardFeature(
      icon: Icons.leaderboard_rounded,
      title: 'Explore World\'s Most Polluted Cities',
      description: 'Live ranking of most polluted cities in the world to '
          'know your city\'s rank.',
      onTap: (context) => context.pushNamed(RankingWidget.routeName),
      previewBuilder: _rankingPreview,
    ),
    _DashboardFeature(
      icon: Icons.favorite_rounded,
      title: 'Check Air Quality for Your Favourite Spot',
      description: 'Follow your favourite locations for timely updates, '
          'insights and informed decision.',
      onTap: (context) => context.pushNamed(FavouritesWidget.routeName),
      previewBuilder: _favouritesPreview,
    ),
    _DashboardFeature(
      icon: Icons.insights_rounded,
      title: 'Historical Insights of Your Air Quality',
      description: 'See what you have breathed with historical data '
          'patterns as monthly and weekly air quality data monitoring.',
      onTap: (context) => context.pushNamed(HistoricalWidget.routeName),
      previewBuilder: _historicalPreview,
    ),
    _DashboardFeature(
      icon: Icons.health_and_safety_rounded,
      title: 'Get Health Advice for Air Quality in Your Area',
      description: 'Follow these advices to protect yourself from air '
          'pollution exposure and stay healthy.',
      onTap: (context) => context.pushNamed(HealthAdviceWidget.routeName),
      previewBuilder: _healthAdvicePreview,
    ),
  ];

  Widget _featureCard(BuildContext context, _DashboardFeature feature) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => feature.onTap(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: theme.lime,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(feature.icon, color: theme.raisinBlack, size: 24.0),
                ),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: _manrope(context,
                            size: 15.0,
                            weight: FontWeight.w800,
                            height: 1.25),
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        feature.description,
                        style: _manrope(context,
                            size: 12.0,
                            weight: FontWeight.w500,
                            color: theme.secondaryText,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.0),
                Icon(Icons.chevron_right_rounded,
                    color: theme.secondaryText, size: 22.0),
              ],
            ),
            SizedBox(height: 14.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: feature.previewBuilder(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewPlaceholder(BuildContext context, String message) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 40.0,
      child: Center(
        child: Text(
          message,
          style: _manrope(context,
              size: 11.5, weight: FontWeight.w600, color: theme.secondaryText),
        ),
      ),
    );
  }

  Widget _mapPreview(BuildContext context) {
    final hasLocation =
        FFAppState().latitude != 0.0 || FFAppState().longitude != 0.0;
    if (!hasLocation) {
      return _previewPlaceholder(context, 'Locating you...');
    }
    final here = LatLng(FFAppState().latitude, FFAppState().longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: SizedBox(
        height: 110.0,
        child: FlutterFlowGoogleMap(
          controller: _previewMapController,
          initialLocation: here,
          markers: [FlutterFlowMarker('current', here)],
          markerColor: GoogleMarkerColor.green,
          mapType: MapType.normal,
          style: GoogleMapStyle.airQuality,
          initialZoom: 11.0,
          allowInteraction: false,
          allowZoom: false,
          showZoomControls: false,
          showLocation: false,
          showCompass: false,
          showMapToolbar: false,
          showTraffic: false,
        ),
      ),
    );
  }

  Widget _rankingPreview(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_topRankings == null) {
      return _previewPlaceholder(context, 'Loading rankings...');
    }
    if (_topRankings!.isEmpty) {
      return _previewPlaceholder(context, 'Rankings unavailable right now.');
    }
    return Column(
      children: _topRankings!.take(3).toList().asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final city = entry.value;
        final color =
            city.aqi > 0 ? epaColor(city.aqi) : theme.secondaryText;
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 18.0,
                child: Text('$rank',
                    style: _manrope(context,
                        size: 12.0,
                        weight: FontWeight.w800,
                        color: theme.secondaryText)),
              ),
              Expanded(
                child: Text(city.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _manrope(context,
                        size: 12.5, weight: FontWeight.w700)),
              ),
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text('${city.aqi}',
                    style: _manrope(context,
                        size: 10.5, weight: FontWeight.w800, color: color)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _favouritesPreview(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_previewFavourites.isEmpty) {
      return _previewPlaceholder(
          context, 'No favourites yet - tap to add one.');
    }
    return Column(
      children: _previewFavourites.take(2).map((fav) {
        final name = fav['name'] as String;
        final aqi = _favouriteAqi[name];
        final color =
            (aqi != null && aqi > 0) ? epaColor(aqi) : theme.secondaryText;
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14.0, color: theme.slateDeep),
              SizedBox(width: 6.0),
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _manrope(context,
                        size: 12.5, weight: FontWeight.w700)),
              ),
              Text(
                aqi == null ? '...' : (aqi > 0 ? '$aqi' : '--'),
                style: _manrope(context,
                    size: 11.0, weight: FontWeight.w800, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _historicalPreview(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_weekHistory == null) {
      return _previewPlaceholder(context, 'Loading trend...');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46.0,
          width: double.infinity,
          child: FlutterFlowLineChart(
            data: [
              FFLineChartData(
                xData: _weekHistory!.xValues,
                yData: _weekHistory!.yValues,
                settings: LineChartBarData(
                  color: theme.lime,
                  barWidth: 3.0,
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.lime.withOpacity(0.15),
                  ),
                ),
              ),
            ],
            chartStylingInfo: ChartStylingInfo(
              backgroundColor: Colors.transparent,
              showBorder: false,
            ),
            axisBounds: AxisBounds(),
            xAxisLabelInfo: AxisLabelInfo(),
            yAxisLabelInfo: AxisLabelInfo(),
          ),
        ),
        SizedBox(height: 6.0),
        Text(
          'This week avg: ${_weekHistory!.average} AQI '
          '(${_weekHistory!.minAqi}-${_weekHistory!.maxAqi})',
          style: _manrope(context,
              size: 11.0, weight: FontWeight.w600, color: theme.secondaryText),
        ),
      ],
    );
  }

  Widget _healthAdvicePreview(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final (icon, message) = _recommendationFor(FFAppState().healthRisk);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.0, color: theme.slateDeep),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _manrope(context,
                size: 11.5,
                weight: FontWeight.w600,
                color: theme.secondaryText,
                height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _pollutantTile(
      BuildContext context, String label, double value, String unit, int index) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: 118.0,
      margin: EdgeInsetsDirectional.only(end: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: _manrope(context, size: 14.0, weight: FontWeight.w700),
              ),
              Icon(
                Icons.north_east_rounded,
                color: theme.secondaryText,
                size: 14.0,
              ),
            ],
          ),
          SizedBox(height: 14.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value > 0
                    ? (value < 10
                        ? value.toStringAsFixed(1)
                        : value.toStringAsFixed(0))
                    : '--',
                style: _manrope(context,
                    size: 28.0, weight: FontWeight.w800, height: 1.0),
              ),
              SizedBox(width: 4.0),
              Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: Text(
                  unit,
                  style: _manrope(context,
                      size: 10.0,
                      weight: FontWeight.w600,
                      color: theme.secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: (80 * index).ms,
            duration: 250.ms,
            curve: Curves.easeOut)
        .moveY(
            delay: (80 * index).ms,
            begin: 14.0,
            end: 0.0,
            duration: 300.ms,
            curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final horizontalPad = MediaQuery.sizeOf(context).width * 0.06;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            alignment: AlignmentDirectional(0.0, 0.0),
            children: [
              SingleChildScrollView(
                primary: false,
                controller: _model.columnController,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      horizontalPad, 18.0, horizontalPad, 120.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Header: location pill + profile ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                6.0, 6.0, 18.0, 6.0),
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 38.0,
                                  height: 38.0,
                                  decoration: BoxDecoration(
                                    color: theme.slateDeep,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.home_rounded,
                                    color: theme.lime,
                                    size: 20.0,
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
                                      style: _manrope(context,
                                          size: 14.0, weight: FontWeight.w800),
                                    ),
                                    Text(
                                      currentUserDisplayName.isNotEmpty
                                          ? 'Hi, ${currentUserDisplayName.split(' ').first}'
                                          : 'Current location',
                                      style: _manrope(context,
                                          size: 11.0,
                                          weight: FontWeight.w500,
                                          color: theme.secondaryText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(ProfileWidget.routeName);
                            },
                            child: Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: theme.slateDeep,
                                size: 22.0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 26.0),

                      // ---------- Title ----------
                      Container(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            14.0, 6.0, 14.0, 6.0),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: theme.lime,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.slateDeep,
                                  width: 1.0,
                                ),
                              ),
                            )
                                .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: true))
                                .fade(
                                    begin: 0.3,
                                    end: 1.0,
                                    duration: 700.ms,
                                    curve: Curves.easeInOut),
                            SizedBox(width: 6.0),
                            Text(
                              'Real-time',
                              style: _manrope(context,
                                  size: 13.0, weight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Air quality data',
                        style: _manrope(context,
                            size: 34.0, weight: FontWeight.w800, height: 1.1),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation1']!),

                      SizedBox(height: 20.0),

                      // ---------- Hero AQI card ----------
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: theme.lime,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        FFAppState().aqiValue.toString(),
                                        style: _manrope(context,
                                            size: 58.0,
                                            weight: FontWeight.w800,
                                            color: theme.raisinBlack,
                                            height: 1.0),
                                      ),
                                      SizedBox(width: 8.0),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                          'AQI',
                                          style: _manrope(context,
                                              size: 15.0,
                                              weight: FontWeight.w700,
                                              color: theme.raisinBlack),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    FFAppState().currentDateTime,
                                    style: _manrope(context,
                                        size: 11.0,
                                        weight: FontWeight.w600,
                                        color:
                                            theme.raisinBlack.withOpacity(0.55)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.thumb_up_alt_outlined,
                                  color: theme.raisinBlack,
                                  size: 22.0,
                                ),
                                SizedBox(height: 8.0),
                                SizedBox(
                                  width: 120.0,
                                  child: Text(
                                    FFAppState().healthRisk.isNotEmpty
                                        ? FFAppState().healthRisk
                                        : 'Fetching air data...',
                                    style: _manrope(context,
                                        size: 16.0,
                                        weight: FontWeight.w700,
                                        color: theme.raisinBlack,
                                        height: 1.25),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation']!),

                      SizedBox(height: 16.0),

                      // ---------- Pollutant tiles ----------
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _model.rowController,
                        child: Row(
                          children: [
                            _pollutantTile(context, 'PM2.5',
                                FFAppState().pm25Value, 'ug/m3', 0),
                            _pollutantTile(context, 'PM10',
                                FFAppState().pm10Value, 'ug/m3', 1),
                            _pollutantTile(context, 'O3',
                                FFAppState().o3Value, 'ug/m3', 2),
                            _pollutantTile(context, 'NO2',
                                FFAppState().no2Value, 'ug/m3', 3),
                            _pollutantTile(context, 'SO2',
                                FFAppState().so2Value, 'ug/m3', 4),
                            _pollutantTile(context, 'CO',
                                FFAppState().coValue, 'ug/m3', 5),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.0),

                      // ---------- Health recommendation ----------
                      _healthRecommendationCard(context),

                      SizedBox(height: 16.0),

                      // ---------- Forecast / chart card ----------
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(ChartFullWidget.routeName);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: theme.slate,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Air Quality Forecast',
                                    style: _manrope(context,
                                        size: 16.0,
                                        weight: FontWeight.w700,
                                        color: theme.white),
                                  ),
                                  Container(
                                    width: 36.0,
                                    height: 36.0,
                                    decoration: BoxDecoration(
                                      color: theme.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.north_east_rounded,
                                      color: theme.white,
                                      size: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.0),
                              wrapWithModel(
                                model: _model.chartCardModel,
                                updateCallback: () => safeSetState(() {}),
                                child: ChartCardWidget(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      // ---------- Explore features ----------
                      Text(
                        'Explore',
                        style: _manrope(context,
                            size: 22.0, weight: FontWeight.w800),
                      ),
                      SizedBox(height: 14.0),
                      ..._dashboardFeatures.asMap().entries.map(
                            (entry) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 12.0),
                              child: _featureCard(context, entry.value),
                            ),
                          ),

                      SizedBox(height: 16.0),

                      // ---------- Blog ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'From the blog',
                            style: _manrope(context,
                                size: 22.0, weight: FontWeight.w800),
                          ).animateOnPageLoad(
                              animationsMap['textOnPageLoadAnimation2']!),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(BlogsWidget.routeName);
                            },
                            child: Text(
                              'See all',
                              style: _manrope(context,
                                  size: 13.0,
                                  weight: FontWeight.w700,
                                  color: theme.secondaryText),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.0),
                      Container(
                        width: double.infinity,
                        height: 280.0,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          controller: _model.listViewController,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(BlogsWidget.routeName);
                              },
                              child: wrapWithModel(
                                model: _model.articleCard1Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ArticleCard1Widget(
                                  title: '',
                                  readingTime: '3 min',
                                  image: '',
                                ),
                              ).animateOnPageLoad(animationsMap[
                                  'articleCard1OnPageLoadAnimation']!),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(BlogsWidget.routeName);
                              },
                              child: wrapWithModel(
                                model: _model.articleCard2Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ArticleCard2Widget(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Floating navigation ----------
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: wrapWithModel(
                    model: _model.navigationModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavigationWidget(
                      onScrollDown: () async {
                        await _model.listViewController?.animateTo(
                          _model.listViewController!.position.maxScrollExtent,
                          duration: Duration(milliseconds: 40),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
