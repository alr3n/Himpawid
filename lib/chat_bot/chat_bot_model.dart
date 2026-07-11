import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chat_bot_widget.dart' show ChatBotWidget;
import 'package:flutter/material.dart';

class ChatBotModel extends FlutterFlowModel<ChatBotWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
