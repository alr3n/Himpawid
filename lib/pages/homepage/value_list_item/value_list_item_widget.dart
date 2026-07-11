import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'value_list_item_model.dart';
export 'value_list_item_model.dart';

class ValueListItemWidget extends StatefulWidget {
  const ValueListItemWidget({
    super.key,
    this.icon,
    this.label,
    this.value,
    this.color,
  });

  final Widget? icon;
  final String? label;
  final String? value;
  final Color? color;

  @override
  State<ValueListItemWidget> createState() => _ValueListItemWidgetState();
}

class _ValueListItemWidgetState extends State<ValueListItemWidget> {
  late ValueListItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  void _onAppStateChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ValueListItemModel());
    FFAppState().addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _model.maybeDispose();
    FFAppState().removeListener(_onAppStateChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pollutants = [
      {'label': 'NO₂', 'key': 'NO2'},
      {'label': 'CO', 'key': 'CO'},
      {'label': 'PM10', 'key': 'PM10'},
      {'label': 'O₃', 'key': 'O3'},
      {'label': 'SO₂', 'key': 'SO2'},
      {'label': 'PM25', 'key': 'PM2_5'},
      {'label': 'NH₃', 'key': 'NH3'},
      {'label': 'AQI', 'key': 'AQI'},
    ];

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: List.generate(
              (pollutants.length / 2).ceil(),
              (rowIndex) {
                final startIndex = rowIndex * 2;
                final endIndex = (startIndex + 2).clamp(0, pollutants.length);
                final rowPollutants = pollutants.sublist(startIndex, endIndex);
                return Padding(
                  padding: EdgeInsets.only(bottom: rowIndex < (pollutants.length / 2).ceil() - 1 ? 8.0 : 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: rowPollutants.map((p) {
                      return Padding(
                        padding: EdgeInsets.only(right: rowPollutants.indexOf(p) < rowPollutants.length - 1 ? 8.0 : 0.0),
                        child: _buildPollutantBox(p['label']!, p['key']!),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollutantBox(String label, String key) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(8.0),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.manrope(
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              key == 'AQI' ? FFAppState().aqiValue.toString() : (FFAppState().pollutants[key] ?? 'N/A'),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.manrope(
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).alternate,
                fontSize: 14.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
