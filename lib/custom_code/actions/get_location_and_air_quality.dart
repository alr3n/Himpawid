// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/flutter_flow/flutter_flow_map.dart' show kMapTilerApiKey;
import 'generate_notification.dart';

// OpenWeather key — used for all air quality data (current + forecast).
String get kOpenWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

/// Fetches the device's GPS location, reverse-geocodes it to a city name,
/// and fetches air quality for it - the entry point called on every page
/// that needs "AQI at my current location".
///
/// Every step logs its outcome (`[AQI FLOW]` prefix) so a failure is
/// diagnosable from the console instead of just silently leaving the UI
/// on a default value.
Future<void> getLocationAndAirQuality() async {
  print('[AQI FLOW] getLocationAndAirQuality() started');

  // Get location first
  try {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('[AQI FLOW] Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      FFAppState().update(() {
        FFAppState().currentLocation = 'Location services disabled';
      });
      return;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    print('[AQI FLOW] Location permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('[AQI FLOW] Location permission after request: $permission');
      if (permission == LocationPermission.denied) {
        FFAppState().update(() {
          FFAppState().currentLocation = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      FFAppState().update(() {
        FFAppState().currentLocation = 'Location permission permanently denied';
      });
      return;
    }

    // Get current position. A time limit is essential here: on web,
    // Geolocator.getCurrentPosition() can hang indefinitely (never
    // resolving, never throwing) if the browser's permission prompt is
    // ignored or location is otherwise stuck - without a timeout, that
    // silently blocks every await chained after this call forever
    // (AQI fetch, forecast, dashboard previews, notifications, etc.),
    // which looks exactly like "stuck on loading" with no error at all.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 15),
    );
    print('[AQI FLOW] GPS position: ${position.latitude}, ${position.longitude}');

    // Update app state with coordinates
    FFAppState().update(() {
      FFAppState().latitude = position.latitude;
      FFAppState().longitude = position.longitude;
    });

    final cityName =
        await reverseGeocodeCityName(position.latitude, position.longitude);
    FFAppState().update(() {
      FFAppState().currentLocation = cityName;
    });
  } catch (e) {
    print('[AQI FLOW] GPS fetch failed: $e');
    FFAppState().update(() {
      FFAppState().currentLocation = e is TimeoutException
          ? 'Location request timed out'
          : 'Error getting location';
    });
  }

  // Then get air quality data from OpenWeather
  if (FFAppState().latitude != 0.0 && FFAppState().longitude != 0.0) {
    print('[AQI FLOW] Fetching AQI for '
        '${FFAppState().latitude}, ${FFAppState().longitude}');
    final success =
        await fetchAirQuality(FFAppState().latitude, FFAppState().longitude);
    print('[AQI FLOW] fetchAirQuality succeeded: $success');
  } else {
    print('[AQI FLOW] Skipping AQI fetch - no location available');
  }

  // Update current date and time
  FFAppState().update(() {
    FFAppState().currentDateTime =
        DateFormat('MMMM d, y, h:mm a').format(DateTime.now());
  });

  print('[AQI FLOW] getLocationAndAirQuality() finished');
}

/// Reverse-geocodes [latitude]/[longitude] to a city/municipality name via
/// MapTiler - shared by the device's own location flow above and anything
/// else that needs a place name for arbitrary coordinates (e.g. the AQI map
/// showing the name of wherever the user has panned to).
///
/// Never throws - returns a human-readable fallback string on any failure,
/// since callers use this purely for display.
Future<String> reverseGeocodeCityName(double latitude, double longitude) async {
  final geocodingUrl = 'https://api.maptiler.com/geocoding/'
      '$longitude,$latitude.json?key=$kMapTilerApiKey';

  try {
    final response = await http.get(Uri.parse(geocodingUrl));
    print('[AQI FLOW] Reverse geocoding HTTP ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      return _cityNameFromFeatures(features);
    }

    // A real API failure (bad key, quota, etc.), not "no results" -
    // surface the actual reason instead of a generic message so it's
    // diagnosable.
    print('[AQI FLOW] Reverse geocoding failed: ${response.body.trim()}');
    return 'Location name unavailable';
  } catch (e) {
    print('[AQI FLOW] Reverse geocoding threw: $e');
    return 'Error getting location';
  }
}

/// Picks a city/municipality-level name out of a MapTiler reverse-geocoding
/// `features` list. Each feature carries a `context` array of its parent
/// administrative areas (suburb, municipality, region, country, ...) - the
/// entry whose `id` starts with `municipality.` is MapTiler/OSM's city-level
/// equivalent to Google's old `locality` address component. Falls back to
/// the top result's own name if no such entry is present (e.g. rural areas).
String _cityNameFromFeatures(List<dynamic> features) {
  if (features.isEmpty) return 'Unknown Location';

  for (final f in features) {
    final feature = f as Map<String, dynamic>;
    final context = feature['context'] as List<dynamic>? ?? [];
    for (final c in context) {
      final entry = c as Map<String, dynamic>;
      final id = entry['id'] as String? ?? '';
      if (id.startsWith('municipality.')) {
        return entry['text'] as String? ?? 'Unknown Location';
      }
    }
  }

  final firstFeature = features.first as Map<String, dynamic>;
  return firstFeature['text'] as String? ?? 'Unknown Location';
}

/// Fetches the current air quality for [latitude]/[longitude] from
/// OpenWeather's Air Pollution API and writes the result into [FFAppState]
/// (aqiValue, aqiCategory, healthRisk, gaugeColor, percentages, pollutants,
/// and the individual per-pollutant fields).
///
/// OpenWeather's own `main.aqi` is a coarse 1-5 category, so instead we
/// compute a proper 0-500 US EPA Air Quality Index from the returned PM2.5
/// concentration via [epaAqiFromPm25] — that's the number most users
/// recognize (matches AirNow/IQAir/etc.), and it's "higher = worse" unlike
/// Google's old 0-100 "higher = cleaner" Universal AQI.
///
/// Returns `true` on success. On failure the previous AQI values are left
/// untouched (so the UI doesn't flash back to zero) and a human-readable
/// message is written to [FFAppState.aqiError] instead of only being
/// printed to the console, so callers/UI can distinguish "still loading"
/// from "the fetch actually failed".
Future<bool> fetchAirQuality(double latitude, double longitude) async {
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$kOpenWeatherApiKey');
  print('[AQI FLOW] fetchAirQuality: GET $url');

  try {
    final response = await http.get(url);
    print('[AQI FLOW] fetchAirQuality: HTTP ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(
          _openWeatherErrorMessage(response.body) ?? 'HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final entries = data['list'] as List<dynamic>?;
    if (entries == null || entries.isEmpty) {
      throw Exception('No air quality data available for this location.');
    }

    final components = (entries.first as Map<String, dynamic>)['components']
            as Map<String, dynamic>? ??
        {};
    final pm25 = (components['pm2_5'] as num?)?.toDouble() ?? 0.0;

    final aqi = epaAqiFromPm25(pm25);
    final category = epaCategory(aqi);
    final gaugeColor = epaColor(aqi);
    print('[AQI FLOW] fetchAirQuality: pm2.5=$pm25 -> AQI=$aqi ($category)');

    // Gauge fill: EPA AQI is "higher = worse", capped at 300 (top of "Very
    // Unhealthy") for display purposes — anything beyond just shows full.
    const gaugeCeiling = 300;
    final gaugeProgress = aqi.clamp(0, gaugeCeiling);

    final pollutantsMap = _applyOpenWeatherPollutants(components);
    pollutantsMap['AQI'] = aqi.toString();
    print('[AQI FLOW] fetchAirQuality: pollutants=$pollutantsMap');

    FFAppState().update(() {
      FFAppState().aqiError = '';
      FFAppState().aqiValue = aqi;
      FFAppState().aqiCategory = 'AQI';
      FFAppState().healthRisk = category;
      FFAppState().percentages = [gaugeProgress, gaugeCeiling - gaugeProgress];
      FFAppState().gaugeColor = gaugeColor;
      FFAppState().pollutants = pollutantsMap;
    });
    print('[AQI FLOW] fetchAirQuality: FFAppState updated '
        '(aqiValue=${FFAppState().aqiValue}, healthRisk=${FFAppState().healthRisk})');

    await generateNotification();
    return true;
  } catch (e) {
    print('Error fetching air quality data: $e');
    FFAppState().update(() {
      FFAppState().aqiError = e.toString().replaceFirst('Exception: ', '');
    });
    return false;
  }
}

/// Applies each pollutant's concentration (µg/m³) from OpenWeather's flat
/// `components` map to its dedicated [FFAppState] field (CO, NO2, O3, SO2,
/// PM2.5, PM10, NH3, NO) and returns a display-key -> formatted-value map.
Map<String, String> _applyOpenWeatherPollutants(
    Map<String, dynamic> components) {
  final map = <String, String>{};

  void put(String displayKey, String apiKey, void Function(double) assign) {
    final value = (components[apiKey] as num?)?.toDouble();
    if (value == null) return;
    map[displayKey] = value.toStringAsFixed(2);
    assign(value);
  }

  put('CO', 'co', (v) => FFAppState().coValue = v);
  put('NO', 'no', (v) => FFAppState().noValue = v);
  put('NO2', 'no2', (v) => FFAppState().no2Value = v);
  put('O3', 'o3', (v) => FFAppState().o3Value = v);
  put('SO2', 'so2', (v) => FFAppState().so2Value = v);
  put('PM2_5', 'pm2_5', (v) => FFAppState().pm25Value = v);
  put('PM10', 'pm10', (v) => FFAppState().pm10Value = v);
  put('NH3', 'nh3', (v) => FFAppState().nh3Value = v);

  return map;
}

/// Pulls the human-readable `message` out of an OpenWeather API JSON error
/// body (e.g. "Invalid API key..."), or `null` if the body isn't in that
/// shape.
String? _openWeatherErrorMessage(String body) {
  try {
    final decoded = json.decode(body);
    return decoded['message'] as String?;
  } catch (_) {
    return null;
  }
}

/// US EPA PM2.5 (24-hr average) AQI breakpoints, per the Feb 2024 NAAQS
/// revision (effective May 2024). Each entry is
/// [concentrationLow, concentrationHigh, aqiLow, aqiHigh] in µg/m³.
/// Source: https://en.wikipedia.org/wiki/Air_quality_index
const List<List<double>> _pm25Breakpoints = [
  [0.0, 9.0, 0, 50], // Good
  [9.1, 35.4, 51, 100], // Moderate
  [35.5, 55.4, 101, 150], // Unhealthy for Sensitive Groups
  [55.5, 125.4, 151, 200], // Unhealthy
  [125.5, 225.4, 201, 300], // Very Unhealthy
  [225.5, 325.4, 301, 500], // Hazardous
];

/// Converts a PM2.5 concentration (µg/m³) into a US EPA Air Quality Index
/// value (0-500, higher = worse) via linear interpolation between the
/// official breakpoints in [_pm25Breakpoints].
int epaAqiFromPm25(double pm25) {
  if (pm25 <= 0) return 0;
  for (final bp in _pm25Breakpoints) {
    final concentrationLow = bp[0];
    final concentrationHigh = bp[1];
    final aqiLow = bp[2];
    final aqiHigh = bp[3];
    if (pm25 <= concentrationHigh) {
      final aqi = (aqiHigh - aqiLow) / (concentrationHigh - concentrationLow) *
              (pm25 - concentrationLow) +
          aqiLow;
      return aqi.round().clamp(0, 500);
    }
  }
  return 500; // Beyond the top breakpoint: cap at the Hazardous maximum.
}

/// Standard EPA AQI category name for a given AQI value.
String epaCategory(int aqi) {
  if (aqi <= 50) return 'Good';
  if (aqi <= 100) return 'Moderate';
  if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
  if (aqi <= 200) return 'Unhealthy';
  if (aqi <= 300) return 'Very Unhealthy';
  return 'Hazardous';
}

/// Standard EPA AQI category color for a given AQI value.
Color epaColor(int aqi) {
  if (aqi <= 50) return const Color(0xFF00E400); // Good
  if (aqi <= 100) return const Color(0xFFFFFF00); // Moderate
  if (aqi <= 150) return const Color(0xFFFF7E00); // Unhealthy (sensitive)
  if (aqi <= 200) return const Color(0xFFFF0000); // Unhealthy
  if (aqi <= 300) return const Color(0xFF8F3F97); // Very Unhealthy
  return const Color(0xFF7E0023); // Hazardous
}

/// Fetches the current EPA AQI (0-500, higher = worse) for an arbitrary
/// [latitude]/[longitude] from OpenWeather, without touching [FFAppState].
/// Shared by any feature that needs an AQI lookup for a location other than
/// "wherever the device currently is" (ranking, favourites, etc.) - returns
/// 0 on failure.
Future<int> fetchAqiForCoordinates(double latitude, double longitude) async {
  try {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$kOpenWeatherApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final entries = data['list'] as List<dynamic>?;
      if (entries != null && entries.isNotEmpty) {
        final components = (entries.first as Map<String, dynamic>)['components']
                as Map<String, dynamic>? ??
            {};
        final pm25 = (components['pm2_5'] as num?)?.toDouble() ?? 0.0;
        return epaAqiFromPm25(pm25);
      }
    } else {
      print(
          'OpenWeather Air Pollution API error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error fetching AQI for ($latitude, $longitude): $e');
  }
  return 0;
}
