import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chart_card_model.dart';
export 'chart_card_model.dart';

class ChartCardWidget extends StatefulWidget {
  const ChartCardWidget({super.key});

  @override
  State<ChartCardWidget> createState() => _ChartCardWidgetState();
}

class _ChartCardWidgetState extends State<ChartCardWidget> {
  late ChartCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChartCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FFAppState().chartY.isEmpty
            ? Container(
                width: double.infinity,
                height: 140.0,
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Text(
                  'Loading forecast...',
                  style: GoogleFonts.manrope(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: theme.white.withOpacity(0.6),
                  ),
                ),
              )
            : Container(
          width: double.infinity,
          height: 140.0,
          child: FlutterFlowLineChart(
            data: [
              FFLineChartData(
                xData: FFAppState().chartX,
                yData: FFAppState().chartY,
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
              )
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
        SizedBox(height: 8.0),
        Text(
          'PAST 7 DAYS',
          style: GoogleFonts.manrope(
            fontSize: 10.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: theme.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
