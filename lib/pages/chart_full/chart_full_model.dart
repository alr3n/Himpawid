import '/components/chart_chip_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chart_full_widget.dart' show ChartFullWidget;
import 'package:flutter/material.dart';

class ChartFullModel extends FlutterFlowModel<ChartFullWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ChartChip component.
  late ChartChipModel chartChipModel1;
  // Model for ChartChip component.
  late ChartChipModel chartChipModel2;
  // Model for ChartChip component.
  late ChartChipModel chartChipModel3;

  @override
  void initState(BuildContext context) {
    chartChipModel1 = createModel(context, () => ChartChipModel());
    chartChipModel2 = createModel(context, () => ChartChipModel());
    chartChipModel3 = createModel(context, () => ChartChipModel());
  }

  @override
  void dispose() {
    chartChipModel1.dispose();
    chartChipModel2.dispose();
    chartChipModel3.dispose();
  }
}
