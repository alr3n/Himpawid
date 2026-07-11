import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_of_service_model.dart';
export 'terms_of_service_model.dart';

class TermsOfServiceWidget extends StatefulWidget {
  const TermsOfServiceWidget({super.key});

  static String routeName = 'TermsOfService';
  static String routePath = '/termsOfService';

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget> {
  late TermsOfServiceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsOfServiceModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  static const List<List<String>> _sections = [
    [
      '1. Acceptance of Terms',
      'By downloading, installing, or using the Himpawid mobile application, you agree to be bound by these Terms of Service.',
    ],
    [
      '2. Use of the Service',
      'You agree to use Himpawid only for lawful and intended purposes. You must not:\nPerform activities that may harm the app or its users\nAttempt to bypass security features\nMisuse any data or information collected by the system',
    ],
    [
      '3. Geolocation Usage',
      'Himpawid collects and uses your exact geolocation to provide accurate and real-time features such as:\nAir quality indexing\nLocation-based warnings\nRoute suggestions\nMap and heatmap functionalities\n\nBy using the app, you give permission for Himpawid to:\nAccess your device’s GPS\nTrack your real-time location\nStore geolocation logs when necessary for system operations\n\nYou may disable GPS through your device settings, but doing so may limit core app functionalities.',
    ],
    [
      '4. Data Collection and Database Storage',
      'Himpawid collects certain information that may be stored in our database, such as:\n\nDevice information\nLocation data\nUser activity logs\nAccount-related details (if applicable)\nAll data is used strictly for:\nSystem functionality\nService improvement\nMonitoring environmental conditions\nSafety alerts and notifications\n\nWe do not sell, trade, or rent your personal data to third parties.',
    ],
    [
      '5. User Responsibilities',
      'You agree to:\n\nProvide accurate information\nUse the app responsibly\nReport suspicious or unauthorized activities\nYou are responsible for maintaining the confidentiality of your device and account.',
    ],
    [
      '6. Location Services',
      'Himpawid may use location-based services to provide enhanced features. You can control location sharing through your device settings. We are not responsible for the accuracy of location data or any consequences arising from location-based features.',
    ],
    [
      '7. Intellectual Property',
      'The Himpawid app, including its design, features, and content, is protected by intellectual property laws. You may not copy, modify, distribute, or create derivative works based on our service without explicit permission.',
    ],
    [
      '8. Prohibited Activities',
      'You agree not to: (a) use the service for illegal purposes, (b) attempt to gain unauthorized access to our systems, (c) interfere with other users\' enjoyment of the service, (d) transmit viruses or malicious code, or (e) violate any applicable laws or regulations.',
    ],
    [
      '9. Disclaimers and Limitations',
      'Himpawid is provided \'as is\' without warranties of any kind. We do not guarantee the accuracy, completeness, or reliability of our service. To the fullest extent permitted by law, we disclaim all liability for any damages arising from your use of the service.',
    ],
    [
      '10. Termination',
      'We may terminate or suspend your account at any time for violation of these terms or for any other reason. You may also terminate your account at any time by deleting the app and ceasing to use our services.',
    ],
    [
      '11. Changes to Terms',
      'We reserve the right to modify these Terms of Service at any time. We will notify users of significant changes through the app or other communication methods. Continued use of the service after changes constitutes acceptance of the new terms.',
    ],
    [
      '12. Contact Information',
      'If you have questions about these Terms of Service, please contact us at support@himpawid.com or through the in-app support feature.',
    ],
  ];

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
                  Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => context.safePop(),
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
                        'Terms of Service',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(56.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Last updated: January 15, 2024',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _sections
                          .map((s) => _section(context, s[0], s[1]))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'By using Himpawid, you acknowledge that you have read, '
                    'understood, and agree to be bound by these Terms of '
                    'Service.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: theme.secondaryText,
                      height: 1.4,
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

  Widget _section(BuildContext context, String heading, String body) {
    final theme = FlutterFlowTheme.of(context);
    final isLast = heading == _sections.last[0];
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, isLast ? 0.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: GoogleFonts.manrope(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: theme.primaryText,
            ),
          ),
          SizedBox(height: 6.0),
          Text(
            body,
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: theme.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
