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
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'generate_notification.dart';

// Google Maps Platform key — used only for reverse geocoding (lat/lng ->
// city name). Air quality itself comes from OpenWeather (see below): the
// Google Air Quality API requires a billing-enabled Cloud project, which
// this app's project doesn't have, while Geocoding works on the free tier.
String get kGoogleApiKey => dotenv.env['GOOGLE_GEOCODING_API_KEY'] ?? '';

// OpenWeather key — used for all air quality data (current + forecast).
String get kOpenWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

Future<void> getLocationAndAirQuality() async {
  // Get location first
  try {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      FFAppState().update(() {
        FFAppState().currentLocation = 'Location services disabled';
      });
      return;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // Update app state with coordinates
    FFAppState().update(() {
      FFAppState().latitude = position.latitude;
      FFAppState().longitude = position.longitude;
    });

    // Get city name using Google Geocoding API
    final geocodingUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$kGoogleApiKey';

    try {
      final geocodingResponse = await http.get(Uri.parse(geocodingUrl));
      if (geocodingResponse.statusCode == 200) {
        final geocodingData = json.decode(geocodingResponse.body);
        if (geocodingData['results'] != null &&
            geocodingData['results'].isNotEmpty) {
          String cityName = 'Unknown Location';
          for (var result in geocodingData['results']) {
            for (var component in result['address_components']) {
              if (component['types'].contains('locality')) {
                cityName = component['long_name'];
                break;
              }
            }
            if (cityName != 'Unknown Location') break;
          }
          FFAppState().update(() {
            FFAppState().currentLocation = cityName;
          });
        }
      }
    } catch (e) {
      FFAppState().update(() {
        FFAppState().currentLocation = 'Error getting location';
      });
    }
  } catch (e) {
    FFAppState().update(() {
      FFAppState().currentLocation = 'Error getting location';
    });
  }

  // Then get air quality data from OpenWeather
  if (FFAppState().latitude != 0.0 && FFAppState().longitude != 0.0) {
    await fetchAirQuality(FFAppState().latitude, FFAppState().longitude);
  }

  // Update current date and time
  FFAppState().update(() {
    FFAppState().currentDateTime =
        DateFormat('MMMM d, y, h:mm a').format(DateTime.now());
  });
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

  try {
    final response = await http.get(url);

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

    // Gauge fill: EPA AQI is "higher = worse", capped at 300 (top of "Very
    // Unhealthy") for display purposes — anything beyond just shows full.
    const gaugeCeiling = 300;
    final gaugeProgress = aqi.clamp(0, gaugeCeiling);

    final pollutantsMap = _applyOpenWeatherPollutants(components);
    pollutantsMap['AQI'] = aqi.toString();

    FFAppState().update(() {
      FFAppState().aqiError = '';
      FFAppState().aqiValue = aqi;
      FFAppState().aqiCategory = 'AQI';
      FFAppState().healthRisk = category;
      FFAppState().percentages = [gaugeProgress, gaugeCeiling - gaugeProgress];
      FFAppState().gaugeColor = gaugeColor;
      FFAppState().pollutants = pollutantsMap;
    });

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
