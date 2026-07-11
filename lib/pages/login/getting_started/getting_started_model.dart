import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'getting_started_widget.dart' show GettingStartedWidget;
import 'package:flutter/material.dart';

class GettingStartedModel extends FlutterFlowModel<GettingStartedWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for NameField widget.
  FocusNode? nameFieldFocusNode;
  TextEditingController? nameFieldTextController;
  String? Function(BuildContext, String?)? nameFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFieldFocusNode?.dispose();
    nameFieldTextController?.dispose();
  }
}
