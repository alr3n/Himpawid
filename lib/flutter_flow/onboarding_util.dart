import 'package:shared_preferences/shared_preferences.dart';

const String _kOnboardingShownKey = 'himpawid_onboarding_shown';

/// Whether the welcome/onboarding carousel has already been shown on this
/// device - stored locally (not per-account), so it's shown at most once
/// per install regardless of which user signs in.
Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingShownKey) ?? false;
}

Future<void> markOnboardingShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingShownKey, true);
}
