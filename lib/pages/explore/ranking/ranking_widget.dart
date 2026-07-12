import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/actions/get_location_and_air_quality.dart'
    show epaColor, epaCategory;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ranking_model.dart';
export 'ranking_model.dart';

class RankingWidget extends StatefulWidget {
  const RankingWidget({super.key});

  static String routeName = 'Ranking';
  static String routePath = '/ranking';

  @override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget> {
  late RankingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<actions.CityAqi>? _rankings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RankingModel());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
    });
    try {
      final result = await actions.fetchCityRankings();
      if (mounted) {
        setState(() {
          _rankings = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Couldn\'t load rankings. Please try again.';
        });
      }
    }
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
          child: RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 30.0),
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
                          'World Ranking',
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
                      padding: EdgeInsetsDirectional.fromSTEB(
                          56.0, 0.0, 0.0, 0.0),
                      child: Text(
                        'Live ranking of major cities by air quality',
                        style: GoogleFonts.manrope(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    if (_error != null)
                      _messageCard(context, _error!)
                    else if (_rankings == null)
                      _loadingCard(context)
                    else
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Column(
                          children: _rankings!
                              .asMap()
                              .entries
                              .expand((entry) => [
                                    _rankRow(context, entry.value, entry.key),
                                    if (entry.key < _rankings!.length - 1)
                                      Divider(
                                        height: 1.0,
                                        indent: 72.0,
                                        endIndent: 16.0,
                                        color: theme.alternate,
                                      ),
                                  ])
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.lime),
            SizedBox(height: 16.0),
            Text(
              'Fetching live rankings...',
              style: GoogleFonts.manrope(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(BuildContext context, String message) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
            ),
          ),
          SizedBox(height: 12.0),
          TextButton(
            onPressed: _load,
            child: Text(
              'Retry',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: theme.slateDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(BuildContext context, actions.CityAqi entry, int index) {
    final theme = FlutterFlowTheme.of(context);
    final color = entry.aqi > 0 ? epaColor(entry.aqi) : theme.secondaryText;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 28.0,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.manrope(
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
                color: theme.secondaryText,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.city,
                  style: GoogleFonts.manrope(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  entry.country,
                  style: GoogleFonts.manrope(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              entry.aqi > 0 ? '${entry.aqi} · ${epaCategory(entry.aqi)}' : '--',
              style: GoogleFonts.manrope(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: (30 * index).ms, duration: 200.ms, curve: Curves.easeOut);
  }
}
