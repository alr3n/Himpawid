import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'health_advice_model.dart';
export 'health_advice_model.dart';

class HealthAdviceWidget extends StatefulWidget {
  const HealthAdviceWidget({super.key});

  static String routeName = 'HealthAdvice';
  static String routePath = '/healthAdvice';

  @override
  State<HealthAdviceWidget> createState() => _HealthAdviceWidgetState();
}

class _Condition {
  const _Condition({
    required this.icon,
    required this.title,
    required this.tips,
  });

  final IconData icon;
  final String title;
  final List<String> tips;
}

class _HealthAdviceWidgetState extends State<HealthAdviceWidget> {
  late HealthAdviceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_Condition> _conditions = [
    _Condition(
      icon: Icons.air_rounded,
      title: 'Asthma',
      tips: [
        'Keep your rescue inhaler with you, especially on days with '
            'elevated AQI.',
        'Check the AQI before heading out and limit outdoor exertion when '
            'it\'s Unhealthy or worse.',
        'Keep windows closed and run an air purifier indoors on poor air '
            'days.',
      ],
    ),
    _Condition(
      icon: Icons.favorite_rounded,
      title: 'Heart Issues',
      tips: [
        'Polluted air puts extra strain on the cardiovascular system - '
            'avoid strenuous outdoor activity when the AQI is elevated.',
        'Watch for chest tightness, shortness of breath, or unusual '
            'fatigue on high-pollution days.',
        'Follow your doctor\'s guidance on safe exertion levels.',
      ],
    ),
    _Condition(
      icon: Icons.grass_rounded,
      title: 'Allergies',
      tips: [
        'Pollution can irritate airways alongside pollen, making allergy '
            'symptoms worse.',
        'Keep windows closed and shower after spending time outdoors on '
            'high-AQI days.',
        'Talk to your doctor about antihistamines if symptoms flare up.',
      ],
    ),
    _Condition(
      icon: Icons.face_rounded,
      title: 'Sinus',
      tips: [
        'Poor air quality can irritate sinus passages and worsen '
            'congestion.',
        'A saline rinse can help clear irritants after outdoor exposure.',
        'Running a humidifier indoors can ease dryness and irritation.',
      ],
    ),
    _Condition(
      icon: Icons.sick_rounded,
      title: 'Cold/Flu',
      tips: [
        'Polluted air can worsen respiratory symptoms and slow recovery '
            'while you\'re sick.',
        'Rest indoors and avoid unnecessary outdoor exposure on high-AQI '
            'days.',
        'Stay hydrated to help your body recover.',
      ],
    ),
    _Condition(
      icon: Icons.monitor_heart_rounded,
      title: 'Chronic (COPD)',
      tips: [
        'People with COPD are especially sensitive to air pollution - '
            'follow your action plan closely.',
        'Avoid outdoor activity when the AQI is Unhealthy or worse.',
        'Keep prescribed medications and supplemental oxygen accessible.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HealthAdviceModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                        'Health Advice',
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
                      'Follow these tips to protect yourself from air '
                      'pollution exposure and stay healthy.',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ..._conditions.asMap().entries.map(
                        (entry) => Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 14.0),
                          child: _conditionCard(context, entry.value, entry.key),
                        ),
                      ),
                  SizedBox(height: 8.0),
                  Text(
                    'This is general educational guidance, not a substitute '
                    'for professional medical advice. Consult your doctor '
                    'for concerns specific to your health.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 11.0,
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

  Widget _conditionCard(BuildContext context, _Condition condition, int index) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: theme.lime.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(condition.icon, color: theme.slateDeep, size: 22.0),
          ),
          SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.title,
                  style: GoogleFonts.manrope(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText,
                  ),
                ),
                SizedBox(height: 8.0),
                ...condition.tips.map(
                  (tip) => Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                    child: Text(
                      '•  $tip',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: (70 * index).ms, duration: 250.ms, curve: Curves.easeOut)
        .moveY(
            delay: (70 * index).ms,
            begin: 12.0,
            end: 0.0,
            duration: 250.ms,
            curve: Curves.easeOut);
  }
}
