import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_settings_model.dart';
export 'notification_settings_model.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  static String routeName = 'NotificationSettings';
  static String routePath = '/notificationSettings';

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  late NotificationSettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationSettingsModel());

    // Load persisted preferences from the user's Firestore document.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUserReference == null) return;
      try {
        final snap = await currentUserReference!.get();
        final data = snap.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            _model.switchListTileValue1 =
                (data['push_notifications'] as bool?) ?? true;
            _model.switchListTileValue2 =
                (data['email_notifications'] as bool?) ?? false;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _persist(String key, bool value) async {
    if (currentUserReference == null) return;
    try {
      await currentUserReference!.update({key: value});
    } catch (_) {}
  }

  Widget _toggleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required int index,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 14.0),
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.slateDeep, size: 20.0),
          ),
          SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.raisinBlack,
            activeTrackColor: theme.lime,
            inactiveThumbColor: theme.secondaryText,
            inactiveTrackColor: theme.alternate,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (80 * index).ms, duration: 250.ms)
        .moveY(
            delay: (80 * index).ms,
            begin: 14.0,
            end: 0.0,
            duration: 300.ms,
            curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
              Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
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
                    'Notifications',
                    style: GoogleFonts.manrope(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 20.0),
                child: Text(
                  'Choose how Himpawid keeps you informed about the air '
                  'around you.',
                  style: GoogleFonts.manrope(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),

              _toggleCard(
                context,
                icon: Icons.notifications_active_outlined,
                title: 'Push notifications',
                subtitle: 'Air quality alerts on your device',
                value: _model.switchListTileValue1 ??= true,
                onChanged: (v) async {
                  safeSetState(() => _model.switchListTileValue1 = v);
                  await _persist('push_notifications', v);
                },
                index: 0,
              ),
              _toggleCard(
                context,
                icon: Icons.mail_outline_rounded,
                title: 'Email notifications',
                subtitle: 'Weekly air quality summaries by email',
                value: _model.switchListTileValue2 ??= false,
                onChanged: (v) async {
                  safeSetState(() => _model.switchListTileValue2 = v);
                  await _persist('email_notifications', v);
                },
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
