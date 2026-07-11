import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/homepage/blogs/article_card1/article_card1_widget.dart';
import '/pages/homepage/blogs/article_card2/article_card2_widget.dart';
import '/pages/homepage/chart_card/chart_card_widget.dart';
import '/pages/homepage/navigation/navigation_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
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
                value > 0 ? value.toStringAsFixed(0) : '--',
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
                            _pollutantTile(
                                context, 'O3', FFAppState().o3Value, 'ppb', 2),
                            _pollutantTile(context, 'NO2',
                                FFAppState().no2Value, 'ppb', 3),
                            _pollutantTile(context, 'SO2',
                                FFAppState().so2Value, 'ppb', 4),
                            _pollutantTile(
                                context, 'CO', FFAppState().coValue, 'ppb', 5),
                          ],
                        ),
                      ),

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

                      SizedBox(height: 28.0),

                      // ---------- Blog ----------
                      Text(
                        'From the blog',
                        style: _manrope(context,
                            size: 22.0, weight: FontWeight.w800),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation2']!),
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
                            wrapWithModel(
                              model: _model.articleCard1Model,
                              updateCallback: () => safeSetState(() {}),
                              child: ArticleCard1Widget(
                                title: '',
                                readingTime: '3 min',
                                image: '',
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'articleCard1OnPageLoadAnimation']!),
                            wrapWithModel(
                              model: _model.articleCard2Model,
                              updateCallback: () => safeSetState(() {}),
                              child: ArticleCard2Widget(),
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
