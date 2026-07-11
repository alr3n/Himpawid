import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_card1_model.dart';
export 'article_card1_model.dart';

class ArticleCard1Widget extends StatefulWidget {
  const ArticleCard1Widget({
    super.key,
    this.title,
    this.readingTime,
    this.image,
  });

  final String? title;
  final String? readingTime;
  final String? image;

  @override
  State<ArticleCard1Widget> createState() => _ArticleCard1WidgetState();
}

class _ArticleCard1WidgetState extends State<ArticleCard1Widget> {
  late ArticleCard1Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ArticleCard1Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: 190.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/building.png',
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: AlignmentDirectional(0.0, -0.04),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'What the AQI Colors Really Mean',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.87),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Ever wondered what those AQI colors stand for? Green means clean air, while red signals unhealthy conditions. Learn how to interpret AQI numbers and protect yourself outdoors.',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
