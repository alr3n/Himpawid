import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_card2_model.dart';
export 'article_card2_model.dart';

class ArticleCard2Widget extends StatefulWidget {
  const ArticleCard2Widget({
    super.key,
    this.title,
    this.readingTime,
    this.image,
  });

  final String? title;
  final String? readingTime;
  final String? image;

  @override
  State<ArticleCard2Widget> createState() => _ArticleCard2WidgetState();
}

class _ArticleCard2WidgetState extends State<ArticleCard2Widget> {
  late ArticleCard2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ArticleCard2Model());
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
                'assets/images/womanwearingmask.jpg',
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: AlignmentDirectional(0.0, -0.04),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '5 Easy Ways to Protect Your Lungs',
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
                alignment: AlignmentDirectional(0.0, 0.81),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Avoid outdoor workouts, use an air purifier, and keep windows closed. These small changes can make a big difference when air quality drops.',
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
