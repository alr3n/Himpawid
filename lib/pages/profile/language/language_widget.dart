import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_model.dart';
export 'language_model.dart';

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({super.key});

  static String routeName = 'Language';
  static String routePath = '/language';

  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  late LanguageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _selected = 'en';
  bool _initialized = false;

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'fil', 'name': 'Filipino', 'native': 'Tagalog'},
    {'code': 'ceb', 'name': 'Cebuano', 'native': 'Binisaya'},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LanguageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _select(String code) async {
    final theme = FlutterFlowTheme.of(context);
    final available = FFLocalizations.languages().contains(code);

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This language is coming soon!',
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
      return;
    }

    setState(() => _selected = code);
    MyApp.of(context).setLocale(code);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language updated',
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (!_initialized) {
      _selected = FFLocalizations.of(context).languageCode;
      _initialized = true;
    }
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
                    'Language',
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
                  'Choose the language you want Himpawid to use.',
                  style: GoogleFonts.manrope(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                  ),
                ),
              ),

              ...List.generate(_languages.length, (i) {
                final lang = _languages[i];
                final code = lang['code']!;
                final available =
                    FFLocalizations.languages().contains(code);
                final selected = _selected == code;

                return InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _select(code),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 14.0),
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: selected ? theme.lime : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.lime
                                : theme.primaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.translate_rounded,
                            color: selected
                                ? theme.raisinBlack
                                : theme.slateDeep,
                            size: 20.0,
                          ),
                        ),
                        SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['name']!,
                                style: GoogleFonts.manrope(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryText,
                                ),
                              ),
                              Text(
                                available
                                    ? lang['native']!
                                    : '${lang['native']!} - coming soon',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 26.0,
                            height: 26.0,
                            decoration: BoxDecoration(
                              color: theme.lime,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: theme.raisinBlack,
                              size: 16.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (80 * i).ms, duration: 250.ms)
                    .moveY(
                        delay: (80 * i).ms,
                        begin: 14.0,
                        end: 0.0,
                        duration: 300.ms,
                        curve: Curves.easeOut);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
