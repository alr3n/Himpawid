import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    _model.yourNameTextController ??=
        TextEditingController(text: currentUserDisplayName);
    _model.yourNameFocusNode ??= FocusNode();

    _model.cityTextController ??=
        TextEditingController(text: currentPhoneNumber);
    _model.cityFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    final theme = FlutterFlowTheme.of(context);
    final name = _model.yourNameTextController?.text.trim() ?? '';
    final phone = _model.cityTextController?.text.trim() ?? '';

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your name',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: theme.white,
            ),
          ),
          backgroundColor: theme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Update Firebase Auth profile
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

      // Update the users collection document
      if (currentUserReference != null) {
        await currentUserReference!.update(createUsersRecordData(
          displayName: name,
          phoneNumber: phone,
        ));
      }

      await authManager.refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: theme.raisinBlack,
            ),
          ),
          backgroundColor: theme.lime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      );
      context.safePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save changes: $e',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: theme.white,
            ),
          ),
          backgroundColor: theme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 8.0),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: theme.primaryText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: theme.secondaryText,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: theme.secondaryText, size: 20.0)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
            ),
            style: GoogleFonts.manrope(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ),
      ],
    );
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
                        'Edit profile',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.0),

                  // ---------- Avatar ----------
                  Center(
                    child: Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: BoxDecoration(
                        color: theme.lime,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.slateDeep,
                          width: 3.0,
                        ),
                      ),
                      child: currentUserPhoto.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(48.0),
                              child: Image.network(
                                currentUserPhoto,
                                width: 96.0,
                                height: 96.0,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              color: theme.raisinBlack,
                              size: 48.0,
                            ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 250.ms)
                      .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 300.ms,
                          curve: Curves.easeOut),

                  SizedBox(height: 28.0),

                  _field(
                    context,
                    label: 'Display name',
                    hint: 'Your name',
                    controller: _model.yourNameTextController,
                    focusNode: _model.yourNameFocusNode,
                    icon: Icons.person_outline_rounded,
                  ),

                  SizedBox(height: 18.0),

                  _field(
                    context,
                    label: 'Phone number',
                    hint: 'Optional',
                    controller: _model.cityTextController,
                    focusNode: _model.cityFocusNode,
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_outlined,
                  ),

                  SizedBox(height: 18.0),

                  // ---------- Email (read-only) ----------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 8.0),
                        child: Text(
                          'Email',
                          style: GoogleFonts.manrope(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 16.0, 20.0, 16.0),
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mail_outline_rounded,
                                color: theme.secondaryText, size: 20.0),
                            SizedBox(width: 12.0),
                            Text(
                              currentUserEmail.isNotEmpty
                                  ? currentUserEmail
                                  : 'Not signed in',
                              style: GoogleFonts.manrope(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.0),

                  // ---------- Save ----------
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: _saving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      height: 54.0,
                      decoration: BoxDecoration(
                        color: theme.lime,
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: _saving
                          ? SizedBox(
                              width: 22.0,
                              height: 22.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.raisinBlack),
                              ),
                            )
                          : Text(
                              'Save changes',
                              style: GoogleFonts.manrope(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800,
                                color: theme.raisinBlack,
                              ),
                            ),
                    ),
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
