import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'navigation_model.dart';
export 'navigation_model.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({
    super.key,
    required this.onScrollDown,
  });

  final Future Function()? onScrollDown;

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  late NavigationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavigationModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 592.5,
      height: 49.4,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(-0.7, 0.0),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 50.0,
                        fillColor: FlutterFlowTheme.of(context).secondary,
                        hoverColor: FlutterFlowTheme.of(context).alternate,
                        hoverIconColor: FlutterFlowTheme.of(context).secondary,
                        icon: Icon(
                          Icons.home,
                          color: FlutterFlowTheme.of(context).alternate,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(HomePageWidget.routeName);
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.32, 3.94),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 50.0,
                        fillColor: FlutterFlowTheme.of(context).secondary,
                        hoverColor: FlutterFlowTheme.of(context).alternate,
                        hoverIconColor: FlutterFlowTheme.of(context).secondary,
                        icon: Icon(
                          Icons.notifications,
                          color: FlutterFlowTheme.of(context).alternate,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(NotificationWidget.routeName);
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.7, 3.94),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 50.0,
                        fillColor: FlutterFlowTheme.of(context).secondary,
                        hoverColor: FlutterFlowTheme.of(context).alternate,
                        hoverIconColor: FlutterFlowTheme.of(context).alternate,
                        icon: Icon(
                          Icons.wechat_sharp,
                          color: FlutterFlowTheme.of(context).alternate,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(ChatBotWidget.routeName);
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(-0.2, 0.0),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 50.0,
                        fillColor: FlutterFlowTheme.of(context).secondary,
                        icon: Icon(
                          Icons.map,
                          color: FlutterFlowTheme.of(context).alternate,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(HeatmapWidget.routeName);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
