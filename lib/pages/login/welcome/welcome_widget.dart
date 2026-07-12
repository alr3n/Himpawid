import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/onboarding_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    this.icon,
    this.lottieAsset,
    required this.blobColor,
    required this.iconColor,
  });

  final String title;
  final String description;
  final IconData? icon;
  final String? lottieAsset;
  final Color blobColor;
  final Color iconColor;
}

/// First-login onboarding carousel - shown once per device (gated by a
/// SharedPreferences flag, see onboarding_util.dart), then never again
/// unless that preference is cleared. Reachable both right after a
/// successful sign-in (see login_widget.dart) and, defensively, via any
/// other path that lands here (e.g. FirstSlideWidget's "Begin" button on a
/// returning session) - either way, it self-checks the flag on load and
/// skips straight to the dashboard if onboarding was already completed.
class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = '/welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late WelcomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  int _currentPage = 0;

  // null while checking the stored preference, false while redirecting
  // away, true once it's confirmed this device hasn't seen onboarding yet.
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());
    _pageController = PageController()..addListener(_onScroll);
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _onScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage && mounted) {
      setState(() => _currentPage = page);
    }
  }

  Future<void> _checkOnboardingStatus() async {
    final seen = await hasSeenOnboarding();
    if (!mounted) return;
    if (seen) {
      setState(() => _showOnboarding = false);
      context.goNamed(HomePageWidget.routeName);
    } else {
      setState(() => _showOnboarding = true);
    }
  }

  Future<void> _finishOnboarding() async {
    await markOnboardingShown();
    if (!mounted) return;
    context.goNamed(HomePageWidget.routeName);
  }

  void _nextPage(int pageCount) {
    if (_currentPage >= pageCount - 1) return;
    _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  List<_OnboardingPage> _pages(FlutterFlowTheme theme) => [
        _OnboardingPage(
          title: 'Welcome to Himpawid',
          description:
              'Monitor real-time air quality and environmental conditions wherever you are.',
          icon: Icons.air_rounded,
          blobColor: theme.limeSoft,
          iconColor: theme.slateDeep,
        ),
        _OnboardingPage(
          title: 'Explore the AQI Map',
          description:
              'View live air quality levels around your location with an interactive map and detailed AQI information.',
          icon: Icons.map_rounded,
          blobColor: theme.azureWeb,
          iconColor: theme.slateDeep,
        ),
        _OnboardingPage(
          title: 'Stay Informed',
          description:
              'Get personalized AQI alerts, historical trends, and a built-in assistant to help you make healthier decisions.',
          lottieAsset: 'assets/jsons/hot-circle.json',
          blobColor: theme.limeSoft,
          iconColor: theme.slateDeep,
        ),
        _OnboardingPage(
          title: 'Let\'s Get Started',
          description:
              'Everything is ready. Explore Himpawid and stay aware of your environment.',
          lottieAsset: 'assets/jsons/check.json',
          blobColor: theme.limeSoft,
          iconColor: theme.slateDeep,
        ),
      ];

  Widget _illustration(_OnboardingPage page) {
    return Container(
      width: 220.0,
      height: 220.0,
      decoration: BoxDecoration(
        color: page.blobColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: page.lottieAsset != null
          ? Lottie.asset(
              page.lottieAsset!,
              width: 160.0,
              height: 160.0,
              fit: BoxFit.contain,
            )
          : Icon(page.icon, size: 96.0, color: page.iconColor),
    );
  }

  Widget _pageContent(BuildContext context, _OnboardingPage page) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _illustration(page),
          SizedBox(height: 40.0),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
              color: theme.primaryText,
            ),
          ),
          SizedBox(height: 14.0),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: theme.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps each page's content with a subtle fade + scale that tracks how
  /// far the page is from the currently-centered one, so swiping between
  /// pages feels like a soft crossfade rather than a hard cut.
  Widget _buildPage(BuildContext context, int index, _OnboardingPage page) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double currentPage = _currentPage.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          currentPage = _pageController.page ?? currentPage;
        }
        final distance = (currentPage - index).abs().clamp(0.0, 1.0);
        final t = 1.0 - distance;
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.92 + 0.08 * t,
            child: child,
          ),
        );
      },
      child: _pageContent(context, page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_showOnboarding != true) {
      // Either still checking the stored preference, or already redirecting
      // to the dashboard - nothing meaningful to render either way.
      return Scaffold(backgroundColor: theme.primaryBackground);
    }

    final pages = _pages(theme);
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480.0),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 52.0),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pages.length,
                        itemBuilder: (context, index) =>
                            _buildPage(context, index, pages[index]),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: pages.length,
                      onDotClicked: (i) => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      effect: ExpandingDotsEffect(
                        dotWidth: 8.0,
                        dotHeight: 8.0,
                        spacing: 8.0,
                        radius: 16.0,
                        dotColor: theme.alternate,
                        activeDotColor: theme.slateDeep,
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: FFButtonWidget(
                        onPressed: isLastPage
                            ? _finishOnboarding
                            : () => _nextPage(pages.length),
                        text: isLastPage ? 'Get Started' : 'Next',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          color: theme.lime,
                          textStyle: GoogleFonts.manrope(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: theme.raisinBlack,
                          ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0),
                  ],
                ),
                if (!isLastPage)
                  PositionedDirectional(
                    top: 4.0,
                    end: 16.0,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _finishOnboarding,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.manrope(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: theme.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
