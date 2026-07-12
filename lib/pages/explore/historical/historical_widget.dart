import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'historical_model.dart';
export 'historical_model.dart';

class HistoricalWidget extends StatefulWidget {
  const HistoricalWidget({super.key});

  static String routeName = 'Historical';
  static String routePath = '/historical';

  @override
  State<HistoricalWidget> createState() => _HistoricalWidgetState();
}

class _HistoricalWidgetState extends State<HistoricalWidget> {
  late HistoricalModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _rangeDays = 7;
  actions.AqiHistoryResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoricalModel());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await actions.fetchAqiHistory(_rangeDays);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      _error = result == null
          ? 'Couldn\'t load historical data for your location.'
          : null;
    });
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
                        'Historical Insights',
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
                      'See what you\'ve breathed with weekly and monthly '
                      'trends.',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(child: _rangeChip(context, 7, 'Weekly')),
                      SizedBox(width: 10.0),
                      Expanded(child: _rangeChip(context, 30, 'Monthly')),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  if (_loading)
                    _statusCard(context, loading: true, message: 'Loading trend...')
                  else if (_error != null)
                    _statusCard(context, loading: false, message: _error!)
                  else
                    _chartCard(context, _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rangeChip(BuildContext context, int days, String label) {
    final theme = FlutterFlowTheme.of(context);
    final selected = _rangeDays == days;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (_rangeDays == days) return;
        setState(() => _rangeDays = days);
        _load();
      },
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
        decoration: BoxDecoration(
          color: selected ? theme.lime : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 13.0,
            fontWeight: FontWeight.w800,
            color: selected ? theme.raisinBlack : theme.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context,
      {required bool loading, required String message}) {
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
            if (loading) ...[
              CircularProgressIndicator(color: theme.lime),
              SizedBox(height: 16.0),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
            if (!loading) ...[
              SizedBox(height: 12.0),
              TextButton(
                onPressed: _load,
                child: Text(
                  'Retry',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700, color: theme.slateDeep),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context, actions.AqiHistoryResult result) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 220.0,
          padding: EdgeInsets.fromLTRB(8.0, 20.0, 20.0, 8.0),
          decoration: BoxDecoration(
            color: theme.slate,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: FlutterFlowLineChart(
            data: [
              FFLineChartData(
                xData: result.xValues,
                yData: result.yValues,
                settings: LineChartBarData(
                  color: theme.lime,
                  barWidth: 4.0,
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
              backgroundColor: theme.slate,
              showBorder: false,
            ),
            axisBounds: AxisBounds(),
            xAxisLabelInfo: AxisLabelInfo(),
            yAxisLabelInfo: AxisLabelInfo(),
          ),
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
                child: _statTile(context, 'Average', result.average, theme.lime)),
            SizedBox(width: 10.0),
            Expanded(
                child: _statTile(
                    context, 'Lowest', result.minAqi, const Color(0xFF00E400))),
            SizedBox(width: 10.0),
            Expanded(
                child: _statTile(
                    context, 'Highest', result.maxAqi, const Color(0xFFFF7E00))),
          ],
        ),
        SizedBox(height: 16.0),
        Text(
          _rangeDays == 7
              ? 'Daily average AQI over the last 7 days.'
              : 'Daily average AQI over the last 30 days.',
          style: GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: theme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _statTile(BuildContext context, String label, int value, Color accent) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value.toString(),
            style: GoogleFonts.manrope(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
