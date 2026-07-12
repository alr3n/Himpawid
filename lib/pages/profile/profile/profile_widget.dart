import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/google_auth.dart' show signOutWithGoogle;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _supportEmail = 'alrendavegramponworkmail@gmail.com';
  static const String _inviteLink = 'https://github.com/alr3n/Himpawid';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------
  Future<void> _contactSupport() async {
    await launchURL(
        'mailto:$_supportEmail?subject=Himpawid%20Support%20Request');
  }

  Future<void> _inviteFriends() async {
    final theme = FlutterFlowTheme.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        title: Text(
          'Invite friends',
          style: GoogleFonts.manrope(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Himpawid so your friends can breathe easy too.',
              style: GoogleFonts.manrope(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: theme.secondaryText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Text(
                _inviteLink,
                style: GoogleFonts.manrope(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.lime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding:
                  EdgeInsetsDirectional.fromSTEB(18.0, 10.0, 18.0, 10.0),
            ),
            onPressed: () async {
              await Clipboard.setData(
                  const ClipboardData(text: _inviteLink));
              Navigator.of(dialogContext).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invite link copied to clipboard',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: theme.white,
                      ),
                    ),
                    backgroundColor: theme.slateDeep,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Copy link',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: theme.raisinBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final theme = FlutterFlowTheme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        title: Text(
          'Log out?',
          style: GoogleFonts.manrope(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        content: Text(
          'You\'ll need to sign in again to see your personalized air '
          'quality data.',
          style: GoogleFonts.manrope(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: theme.secondaryText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding:
                  EdgeInsetsDirectional.fromSTEB(18.0, 10.0, 18.0, 10.0),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Log out',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: theme.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    GoRouter.of(context).prepareAuthEvent();
    // Clear the native Google session too, not just Firebase's - otherwise
    // a later "Continue with Google" silently reauths the same account
    // instead of showing the account picker.
    await signOutWithGoogle().catchError((_) {});
    await authManager.signOut();
    // authenticatedUserStream resets this asynchronously as a side effect
    // of the Firebase auth-state change; clear it synchronously too so
    // nothing reads a stale user document in the meantime.
    currentUserDocument = null;
    GoRouter.of(context).clearRedirectLocation();

    if (!context.mounted) return;
    context.goNamedAuth(LoginWidget.routeName, context.mounted);
  }

  // ------------------------------------------------------------------
  // UI helpers
  // ------------------------------------------------------------------
  Widget _menuRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconBg,
    Color? iconColor,
    Color? titleColor,
    bool showChevron = true,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
        child: Row(
          children: [
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: iconBg ?? theme.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.slateDeep,
                size: 20.0,
              ),
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
                      color: titleColor ?? theme.primaryText,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: theme.secondaryText,
                size: 22.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, String label,
      List<Widget> rows, int index) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 8.0),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: theme.secondaryText,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            children: rows
                .expand((w) => [
                      w,
                      if (w != rows.last)
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
    )
        .animate()
        .fadeIn(
            delay: (90 * index).ms, duration: 250.ms, curve: Curves.easeOut)
        .moveY(
            delay: (90 * index).ms,
            begin: 16.0,
            end: 0.0,
            duration: 300.ms,
            curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever Firebase Auth's sign-in state or the user's
    // Firestore document changes, so a login/logout elsewhere in the app
    // is reflected here immediately without needing to reopen the page.
    return AuthUserStreamWidget(builder: (context) => _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Only show placeholder text when nobody is actually signed in -
    // a signed-in user with a missing field (e.g. no display name on
    // record) should read as "Signed in", not be mistaken for a guest.
    final displayName = !loggedIn
        ? 'Guest'
        : (currentUserDisplayName.isNotEmpty
            ? currentUserDisplayName
            : 'Signed in');
    final email = !loggedIn
        ? 'Not signed in'
        : (currentUserEmail.isNotEmpty ? currentUserEmail : 'Signed in');

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
                  // ---------- Header ----------
                  Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(HomePageWidget.routeName);
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
                        'Profile',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.0),

                  // ---------- Identity card ----------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.slateDeep,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: theme.lime,
                            shape: BoxShape.circle,
                          ),
                          child: currentUserPhoto.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(32.0),
                                  child: Image.network(
                                    currentUserPhoto,
                                    width: 64.0,
                                    height: 64.0,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  color: theme.raisinBlack,
                                  size: 32.0,
                                ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.manrope(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w800,
                                  color: theme.white,
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                email,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: theme.slateMist,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(EditProfileWidget.routeName);
                          },
                          child: Container(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                14.0, 8.0, 14.0, 8.0),
                            decoration: BoxDecoration(
                              color: theme.lime,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.manrope(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w800,
                                color: theme.raisinBlack,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 250.ms, curve: Curves.easeOut)
                      .moveY(
                          begin: 16.0,
                          end: 0.0,
                          duration: 300.ms,
                          curve: Curves.easeOut),

                  SizedBox(height: 24.0),

                  // ---------- Settings ----------
                  _sectionCard(
                    context,
                    'Settings',
                    [
                      _menuRow(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: 'Edit profile',
                        subtitle: 'Name and account details',
                        onTap: () async {
                          context.pushNamed(EditProfileWidget.routeName);
                        },
                      ),
                      _menuRow(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification settings',
                        subtitle: 'Air quality alerts',
                        onTap: () async {
                          context
                              .pushNamed(NotificationSettingsWidget.routeName);
                        },
                      ),
                      _menuRow(
                        context,
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'App language',
                        onTap: () async {
                          context.pushNamed(LanguageWidget.routeName);
                        },
                      ),
                    ],
                    1,
                  ),

                  SizedBox(height: 20.0),

                  // ---------- About ----------
                  _sectionCard(
                    context,
                    'About',
                    [
                      _menuRow(
                        context,
                        icon: Icons.support_agent_rounded,
                        title: 'Support',
                        subtitle: 'Email us your questions',
                        onTap: _contactSupport,
                      ),
                      _menuRow(
                        context,
                        icon: Icons.description_outlined,
                        title: 'Terms of service',
                        onTap: () async {
                          context.pushNamed(TermsOfServiceWidget.routeName);
                        },
                      ),
                      _menuRow(
                        context,
                        icon: Icons.code_rounded,
                        title: 'Developer\'s information',
                        onTap: () async {
                          context.pushNamed(DeveloperInfoWidget.routeName);
                        },
                      ),
                    ],
                    2,
                  ),

                  SizedBox(height: 20.0),

                  // ---------- Community ----------
                  _sectionCard(
                    context,
                    'Community',
                    [
                      _menuRow(
                        context,
                        icon: Icons.group_add_outlined,
                        title: 'Invite friends',
                        subtitle: 'Share Himpawid',
                        onTap: _inviteFriends,
                      ),
                    ],
                    3,
                  ),

                  SizedBox(height: 20.0),

                  // ---------- Logout ----------
                  _sectionCard(
                    context,
                    'Account',
                    [
                      _menuRow(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Log out',
                        iconBg: theme.error.withOpacity(0.1),
                        iconColor: theme.error,
                        titleColor: theme.error,
                        showChevron: false,
                        onTap: _logout,
                      ),
                    ],
                    4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
