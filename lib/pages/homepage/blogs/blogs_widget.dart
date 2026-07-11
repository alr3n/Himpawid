import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blogs_model.dart';
export 'blogs_model.dart';

class BlogsWidget extends StatefulWidget {
  const BlogsWidget({super.key});

  static String routeName = 'Blogs';
  static String routePath = '/blogs';

  @override
  State<BlogsWidget> createState() => _BlogsWidgetState();
}

class _Article {
  const _Article({
    required this.title,
    required this.readingTime,
    required this.image,
    required this.paragraphs,
  });

  final String title;
  final String readingTime;
  final String image;
  final List<String> paragraphs;
}

class _BlogsWidgetState extends State<BlogsWidget> {
  late BlogsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_Article> _articles = [
    _Article(
      title: 'What the AQI Colors Really Mean',
      readingTime: '3 min read',
      image: 'assets/images/building.png',
      paragraphs: [
        'The Air Quality Index (AQI) turns pollutant readings like PM2.5 '
            'into a single number from 0 to 500, and each range is tied to '
            'a color so you can tell how the air is at a glance.',
        'Green (0-50, Good) means air quality is satisfactory and poses '
            'little or no risk. Yellow (51-100, Moderate) is acceptable, '
            'though unusually sensitive individuals may want to consider '
            'limiting prolonged outdoor exertion.',
        'Orange (101-150, Unhealthy for Sensitive Groups) means people '
            'with asthma, heart or lung conditions, older adults, and '
            'children should start reducing prolonged outdoor activity. '
            'Red (151-200, Unhealthy) means everyone may begin to '
            'experience health effects, and sensitive groups may '
            'experience more serious ones.',
        'Purple (201-300, Very Unhealthy) is a health alert: everyone is '
            'more likely to be affected. Maroon (301+, Hazardous) is an '
            'emergency condition - the whole population is more likely to '
            'be affected and outdoor activity should be avoided.',
        'Himpawid computes this number from real pollutant concentration '
            'data so the color you see on your home screen always reflects '
            'this same scale.',
      ],
    ),
    _Article(
      title: '5 Easy Ways to Protect Your Lungs',
      readingTime: '3 min read',
      image: 'assets/images/womanwearingmask.jpg',
      paragraphs: [
        'You don\'t need to overhaul your routine to breathe easier on a '
            'bad air day - a few small habits go a long way.',
        '1. Check the AQI before heading out. A quick look at Himpawid\'s '
            'home screen tells you whether it\'s a good day for outdoor '
            'plans or better to stay indoors.',
        '2. Wear a well-fitted mask outdoors when levels are elevated. An '
            'N95 or KN95 filters fine particles far better than a cloth '
            'mask.',
        '3. Keep windows closed and use an air purifier indoors when the '
            'AQI is high, especially in bedrooms where you spend the most '
            'time.',
        '4. Avoid strenuous outdoor exercise on unhealthy air days - '
            'move a workout indoors or reschedule it for when air quality '
            'improves.',
        '5. Stay hydrated and pay attention to symptoms like coughing or '
            'shortness of breath, especially if you have asthma or another '
            'respiratory condition - and don\'t hesitate to see a doctor if '
            'symptoms persist.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlogsModel());
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
                        'From the blog',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  ..._articles.asMap().entries.map(
                        (entry) => Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 20.0),
                          child: _articleCard(context, entry.value, entry.key),
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

  Widget _articleCard(BuildContext context, _Article article, int index) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            child: Image.asset(
              article.image,
              width: double.infinity,
              height: 160.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    article.readingTime,
                    style: GoogleFonts.manrope(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  article.title,
                  style: GoogleFonts.manrope(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText,
                  ),
                ),
                SizedBox(height: 12.0),
                ...article.paragraphs.map(
                  (p) => Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                    child: Text(
                      p,
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
          ),
        ],
      ),
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
}
