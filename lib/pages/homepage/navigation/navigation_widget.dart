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

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 46.0,
        height: 46.0,
        decoration: BoxDecoration(
          color: isActive ? theme.lime : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? theme.raisinBlack : theme.slateMist,
          size: 22.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: theme.slateDeep,
        boxShadow: [
          BoxShadow(
            blurRadius: 14.0,
            color: Color(0x40000000),
            offset: Offset(0.0, 6.0),
          )
        ],
        borderRadius: BorderRadius.circular(34.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navItem(
            context,
            icon: Icons.home_rounded,
            isActive: true,
            onTap: () {
              context.pushNamed(HomePageWidget.routeName);
            },
          ),
          SizedBox(width: 6.0),
          _navItem(
            context,
            icon: Icons.map_rounded,
            onTap: () {
              context.pushNamed(HeatmapWidget.routeName);
            },
          ),
          SizedBox(width: 6.0),
          _navItem(
            context,
            icon: Icons.notifications_rounded,
            onTap: () {
              context.pushNamed(NotificationWidget.routeName);
            },
          ),
          SizedBox(width: 6.0),
          _navItem(
            context,
            icon: Icons.forum_rounded,
            onTap: () {
              context.pushNamed(ChatBotWidget.routeName);
            },
          ),
        ],
      ),
    );
  }
}
