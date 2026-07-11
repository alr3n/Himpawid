import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'developer_info_model.dart';
export 'developer_info_model.dart';

class DeveloperInfoWidget extends StatefulWidget {
  const DeveloperInfoWidget({super.key});

  static String routeName = 'DeveloperInfo';
  static String routePath = '/developerInfo';

  @override
  State<DeveloperInfoWidget> createState() => _DeveloperInfoWidgetState();
}

class _DeveloperInfoWidgetState extends State<DeveloperInfoWidget> {
  late DeveloperInfoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeveloperInfoModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  static const List<String> _developers = [
    'Alren Dave Grampon – Main Developer',
    'Angel Delgado – Support Developer',
  ];

  static const List<String> _appDetails = [
    'Version: 2.0',
    'Category: Weather',
    'Compatibility: Android, iOS, Web',
    'Language: English',
    'Age Rating: 4+',
    'Copyright: © 2025 DWCC SIT – ITP108L Students',
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
                        'Developer\'s Information',
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
                      'Meet the team behind Himpawid',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  _card(
                    context,
                    'Developers',
                    _developers,
                  ),
                  SizedBox(height: 20.0),
                  _card(
                    context,
                    'App Details',
                    _appDetails,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Thank you for using Himpawid!',
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

  Widget _card(BuildContext context, String heading, List<String> lines) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
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
          SizedBox(height: 10.0),
          ...lines.map(
            (line) => Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
              child: Text(
                line,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: theme.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
