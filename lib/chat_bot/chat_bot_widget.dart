import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/actions/get_location_and_air_quality.dart'
    show epaCategory;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_bot_model.dart';
export 'chat_bot_model.dart';

class _ChatMessage {
  _ChatMessage(this.text, this.isUser);
  final String text;
  final bool isUser;
}

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  static String routeName = 'ChatBot';
  static String routePath = '/chatBot';

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  late ChatBotModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _botTyping = false;

  static const List<String> _suggestions = [
    'What is the AQI right now?',
    'Is it safe to exercise outside?',
    'What is PM2.5?',
    'Should I wear a mask today?',
    'Can I open my windows?',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatBotModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    final name = currentUserDisplayName.isNotEmpty
        ? currentUserDisplayName.split(' ').first
        : 'there';
    _messages.add(_ChatMessage(
        'Hi $name! I\'m the Himpawid assistant. Ask me about the air '
        'quality around you, what the numbers mean, or what\'s safe to do '
        'outside today.',
        false));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _model.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Bot logic: answers based on live air quality data (US EPA AQI,
  // 0-500, HIGHER = WORSE - see get_location_and_air_quality.dart).
  // ---------------------------------------------------------------------

  /// Pulls a place name out of "... in/at/near <place>" so a question like
  /// "what's the aqi in manila?" looks up Manila specifically instead of
  /// silently answering with the device's own current location - which is
  /// what made asking about two different cities return the same answer.
  String? _extractCityQuery(String lowercasedQuestion) {
    final match = RegExp(r'\b(?:in|at|near)\s+([a-z][a-z\s\-]{1,40}?)[\?\.!,]*$')
        .firstMatch(lowercasedQuestion.trim());
    final city = match?.group(1)?.trim();
    return (city == null || city.isEmpty) ? null : city;
  }

  /// Resolves the AQI/location to answer with: if the question named a
  /// specific place, geocode it and fetch that place's real AQI; otherwise
  /// fall back to the device's current location (the previous behavior).
  /// A failed or unmatched place lookup falls back the same way, so a
  /// nonsense phrase never produces a wrong answer - just the same "no
  /// data" or device-location response as before.
  Future<({int aqi, String location, bool hasData})> _resolveAqiContext(
      String lowercasedQuestion) async {
    final cityQuery = _extractCityQuery(lowercasedQuestion);
    if (cityQuery != null) {
      try {
        final results = await actions.searchLocation(cityQuery);
        if (results.isNotEmpty) {
          final place = results.first;
          final aqi = await actions.fetchAqiForCoordinates(
              place.latitude, place.longitude);
          if (aqi > 0) {
            return (aqi: aqi, location: place.name, hasData: true);
          }
        }
      } catch (e) {
        print('[CHATBOT] City lookup for "$cityQuery" failed: $e');
        // fall through to device location below
      }
    }

    final aqi = FFAppState().aqiValue;
    return (
      aqi: aqi,
      location: FFAppState().currentLocation,
      hasData: aqi > 0,
    );
  }

  Future<String> _botReply(String input) async {
    final q = input.toLowerCase();

    String aqiSummary(int aqi, String location, bool hasData) {
      if (!hasData) {
        return 'I don\'t have air quality data yet. Open the home screen '
            'and allow location access so I can check the air around you.';
      }
      final category = epaCategory(aqi);
      return 'The air quality index in '
          '${location.isNotEmpty ? location : 'your area'} is $aqi '
          '($category). Remember: on this scale, HIGHER means WORSE air '
          'quality.';
    }

    String pollutant(String key, String name, String desc) {
      final v = FFAppState().pollutants[key];
      if (v == null || v.isEmpty) {
        return '$name $desc I don\'t have a current reading yet - refresh '
            'the home screen to fetch one.';
      }
      return '$name is currently at $v. $desc';
    }

    if (q.contains('hello') || q.contains('hi ') || q == 'hi' ||
        q.contains('hey')) {
      return 'Hello! Ask me things like "What\'s the AQI right now?" or '
          '"Is it safe to jog outside?"';
    }

    if (q.contains('aqi') || q.contains('air quality') ||
        q.contains('how is the air') || q.contains('air now')) {
      final ctx = await _resolveAqiContext(q);
      return aqiSummary(ctx.aqi, ctx.location, ctx.hasData);
    }

    if (q.contains('pm2.5') || q.contains('pm 2.5') || q.contains('pm25')) {
      return pollutant('PM2_5', 'PM2.5',
          'These are fine particles smaller than 2.5 micrometers - small '
          'enough to reach deep into your lungs. They come from vehicles, '
          'smoke, and industry.');
    }

    if (q.contains('pm10') || q.contains('pm 10')) {
      return pollutant('PM10', 'PM10',
          'These are coarse dust particles from roads, construction, and '
          'pollen. They mostly irritate the nose and throat.');
    }

    if (q.contains('ozone') || q.contains('o3')) {
      return pollutant('O3', 'Ozone (O3)',
          'Ground-level ozone forms when sunlight reacts with pollution. '
          'It peaks on hot, sunny afternoons and can irritate the airways.');
    }

    if (q.contains('no2') || q.contains('nitrogen')) {
      return pollutant('NO2', 'Nitrogen dioxide (NO2)',
          'NO2 mainly comes from vehicle exhaust and power plants.');
    }

    if (q.contains('so2') || q.contains('sulfur') || q.contains('sulphur')) {
      return pollutant('SO2', 'Sulfur dioxide (SO2)',
          'SO2 comes from burning fossil fuels and volcanic activity.');
    }

    if (q.contains('co') && !q.contains('cov')) {
      return pollutant('CO', 'Carbon monoxide (CO)',
          'CO is an odorless gas from incomplete combustion - mostly '
          'traffic in cities.');
    }

    if (q.contains('exercise') || q.contains('run') || q.contains('jog') ||
        q.contains('workout') || q.contains('outside') ||
        q.contains('outdoor')) {
      final ctx = await _resolveAqiContext(q);
      if (!ctx.hasData) return aqiSummary(ctx.aqi, ctx.location, ctx.hasData);
      final category = epaCategory(ctx.aqi);
      if (ctx.aqi <= 50) {
        return 'With an AQI of ${ctx.aqi} ($category), the air is clean - '
            'it\'s a great time for outdoor exercise. Enjoy!';
      } else if (ctx.aqi <= 100) {
        return 'The AQI is ${ctx.aqi} ($category). Light outdoor activity '
            'is fine for most people, but if you\'re sensitive to air '
            'pollution, consider shortening intense workouts.';
      }
      return 'The AQI is ${ctx.aqi} ($category), which means the air is '
          'quite polluted right now. I\'d recommend exercising indoors '
          'today.';
    }

    if (q.contains('mask')) {
      final ctx = await _resolveAqiContext(q);
      if (!ctx.hasData) return aqiSummary(ctx.aqi, ctx.location, ctx.hasData);
      final category = epaCategory(ctx.aqi);
      if (ctx.aqi <= 50) {
        return 'The air is clean right now (AQI ${ctx.aqi}) - no mask '
            'needed for air quality reasons.';
      } else if (ctx.aqi <= 100) {
        return 'AQI is ${ctx.aqi} ($category). A mask isn\'t essential, but '
            'sensitive individuals may want one for longer time outdoors.';
      }
      return 'With AQI at ${ctx.aqi} ($category), a well-fitted N95/KN95 '
          'mask is a good idea if you need to spend time outside.';
    }

    if (q.contains('window')) {
      final ctx = await _resolveAqiContext(q);
      if (!ctx.hasData) return aqiSummary(ctx.aqi, ctx.location, ctx.hasData);
      final category = epaCategory(ctx.aqi);
      if (ctx.aqi <= 50) {
        return 'The air is clean (AQI ${ctx.aqi}) - a great time to '
            'ventilate and open the windows.';
      }
      return 'AQI is ${ctx.aqi} ($category). I\'d keep windows closed for '
          'now and ventilate later when the air improves - check the '
          'forecast on the chart screen.';
    }

    if (q.contains('forecast') || q.contains('later') ||
        q.contains('tomorrow')) {
      final avg = FFAppState().avgLevel;
      final hrs = FFAppState().daysScale;
      if (avg > 0 && hrs > 0) {
        return 'The average forecast AQI for the next $hrs hours is $avg. '
            'You can see the hour-by-hour trend on the forecast chart from '
            'the home screen.';
      }
      return 'Open the forecast chart from the home screen and I\'ll crunch '
          'the numbers - I don\'t have forecast data loaded yet.';
    }

    if (q.contains('scale') || q.contains('mean') || q.contains('what is aqi')
        || q.contains('index')) {
      return 'Himpawid uses the US EPA Air Quality Index: a 0-500 scale '
          'where HIGHER means WORSE air. 0-50 is Good, 51-100 Moderate, '
          '101-150 Unhealthy for Sensitive Groups, 151-200 Unhealthy, '
          '201-300 Very Unhealthy, and 301+ is Hazardous.';
    }

    if (q.contains('where') || q.contains('location')) {
      final location = FFAppState().currentLocation;
      return location.isNotEmpty
          ? 'Your readings are for $location, based on your device '
              'location.'
          : 'I don\'t have your location yet - allow location access on the '
              'home screen.';
    }

    if (q.contains('thank')) {
      return 'You\'re welcome! Breathe easy.';
    }

    return 'I can help with air quality questions - try asking "What\'s the '
        'AQI right now?", "What is PM2.5?", "Should I wear a mask?", or '
        '"Is it safe to exercise outside?" You can also ask about a '
        'specific place, like "What\'s the AQI in Manila?"';
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _model.textController?.text ?? '').trim();
    if (text.isEmpty || _botTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text, true));
      _botTyping = true;
    });
    _model.textController?.clear();
    _scrollToBottom();

    // Run the reply lookup and a minimum typing-indicator delay together,
    // so a fast (cached/no-network) reply still feels natural, but a
    // slower one (e.g. geocoding a named city) isn't held up any longer
    // than it actually takes.
    final results = await Future.wait([
      _botReply(text),
      Future.delayed(const Duration(milliseconds: 650)),
    ]);
    final reply = results[0] as String;

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(reply, false));
      _botTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _bubble(BuildContext context, _ChatMessage m) {
    final theme = FlutterFlowTheme.of(context);
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: m.isUser ? theme.slateDeep : theme.secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.0),
          topRight: Radius.circular(22.0),
          bottomLeft: Radius.circular(m.isUser ? 22.0 : 6.0),
          bottomRight: Radius.circular(m.isUser ? 6.0 : 22.0),
        ),
      ),
      child: Text(
        m.text,
        style: GoogleFonts.manrope(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: m.isUser ? theme.white : theme.primaryText,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment:
            m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!m.isUser) ...[
            Container(
              width: 30.0,
              height: 30.0,
              margin: EdgeInsetsDirectional.only(end: 8.0),
              decoration: BoxDecoration(
                color: theme.lime,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.air_rounded,
                color: theme.raisinBlack,
                size: 16.0,
              ),
            ),
          ],
          Flexible(child: bubble),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
        .moveY(begin: 10.0, end: 0.0, duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _typingIndicator(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget dot(int i) => Container(
          width: 7.0,
          height: 7.0,
          margin: EdgeInsetsDirectional.only(end: 4.0),
          decoration: BoxDecoration(
            color: theme.secondaryText,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(
                begin: 0.2,
                end: 1.0,
                delay: (i * 150).ms,
                duration: 350.ms);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            margin: EdgeInsetsDirectional.only(end: 8.0),
            decoration: BoxDecoration(
              color: theme.lime,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.air_rounded,
              color: theme.raisinBlack,
              size: 16.0,
            ),
          ),
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 12.0, 14.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [dot(0), dot(1), dot(2)],
            ),
          ),
        ],
      ),
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
          child: Column(
            children: [
              // ---------- Header ----------
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 8.0),
                child: Row(
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
                    SizedBox(width: 12.0),
                    Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        color: theme.lime,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.air_rounded,
                        color: theme.raisinBlack,
                        size: 22.0,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Himpawid Assistant',
                          style: GoogleFonts.manrope(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText,
                          ),
                        ),
                        Text(
                          'Air quality helper',
                          style: GoogleFonts.manrope(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------- Messages ----------
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                  children: [
                    ..._messages.map((m) => _bubble(context, m)),
                    if (_botTyping) _typingIndicator(context),
                  ],
                ),
              ),

              // ---------- Suggestions ----------
              Container(
                height: 40.0,
                margin: EdgeInsets.only(bottom: 8.0),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.0),
                  itemBuilder: (context, i) => InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => _sendMessage(_suggestions[i]),
                    child: Container(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: Text(
                        _suggestions[i],
                        style: GoogleFonts.manrope(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------- Input ----------
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          onFieldSubmitted: (_) => _sendMessage(),
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            hintText: 'Ask about the air around you...',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: theme.secondaryText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 14.0, 20.0, 14.0),
                          ),
                          style: GoogleFonts.manrope(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryText,
                          ),
                          validator: _model.textControllerValidator
                              ?.asValidator(context),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => _sendMessage(),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: theme.lime,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: theme.raisinBlack,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
