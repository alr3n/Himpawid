import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'explore_model.dart';
export 'explore_model.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  static String routeName = 'Explore';
  static String routePath = '/explore';

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final void Function(BuildContext context) onTap;
}

class _ExploreWidgetState extends State<ExploreWidget> {
  late ExploreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<_Feature> _features = [
    _Feature(
      icon: Icons.map_rounded,
      title: 'View Your Area\'s Air Quality Conditions on Map',
      description: 'Check air quality condition in your area with '
          'interactive maps for better understanding.',
      onTap: (context) => context.pushNamed(HeatmapWidget.routeName),
    ),
    _Feature(
      icon: Icons.leaderboard_rounded,
      title: 'Explore World\'s Most Polluted Cities',
      description: 'Live ranking of most polluted cities in the world to '
          'know your city\'s rank.',
      onTap: (context) => context.pushNamed(RankingWidget.routeName),
    ),
    _Feature(
      icon: Icons.favorite_rounded,
      title: 'Check Air Quality for Your Favourite Spot',
      description: 'Follow your favourite locations for timely updates, '
          'insights and informed decision.',
      onTap: (context) => context.pushNamed(FavouritesWidget.routeName),
    ),
    _Feature(
      icon: Icons.insights_rounded,
      title: 'Historical Insights of Your Air Quality',
      description: 'See what you have breathed with historical data '
          'patterns as monthly and weekly air quality data monitoring.',
      onTap: (context) => context.pushNamed(HistoricalWidget.routeName),
    ),
    _Feature(
      icon: Icons.health_and_safety_rounded,
      title: 'Get Health Advice for Air Quality in Your Area',
      description: 'Follow these advices to protect yourself from air '
          'pollution exposure and stay healthy.',
      onTap: (context) => context.pushNamed(HealthAdviceWidget.routeName),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExploreModel());
  }

  @override
  void dispose() {
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
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => context.safePop(),
                        child: Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: theme.slateDeep,
                            size: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.0),
                      Text(
                        'Explore',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(56.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Everything you need to understand your air, in one '
                      'place.',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ..._features.asMap().entries.map(
                        (entry) => Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 14.0),
                          child: _featureCard(context, entry.value, entry.key),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureCard(BuildContext context, _Feature feature, int index) {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: theme.lime,
                shape: BoxShape.circle,
              ),
              child: Icon(feature.icon, color: theme.raisinBlack, size: 24.0),
            ),
            SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: GoogleFonts.manrope(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryText,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    feature.description,
                    style: GoogleFonts.manrope(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: theme.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.0),
            Icon(Icons.chevron_right_rounded,
                color: theme.secondaryText, size: 22.0),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: (70 * index).ms, duration: 250.ms, curve: Curves.easeOut)
        .moveY(
            delay: (70 * index).ms,
            begin: 14.0,
            end: 0.0,
            duration: 250.ms,
            curve: Curves.easeOut);
  }
}
