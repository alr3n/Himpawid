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
import 'generate_notification.dart';

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
    final String geocodingApiKey = 'AIzaSyDt6RQVJmjRWo7ZvrJ10je8pEoSZDgAOfU';
    final geocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$geocodingApiKey';

    try {
      final geocodingResponse = await http.get(Uri.parse(geocodingUrl));
      if (geocodingResponse.statusCode == 200) {
        final geocodingData = json.decode(geocodingResponse.body);
        if (geocodingData['results'] != null && geocodingData['results'].isNotEmpty) {
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

  // Then get air quality data (only if we have coordinates)
  if (FFAppState().latitude != 0.0 && FFAppState().longitude != 0.0) {
    final String aqiApiKey = 'e305a2a09e3309305b986b90db6cd155';
    final double lat = FFAppState().latitude;
    final double lon = FFAppState().longitude;

    try {
      final aqiUrl = 'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$aqiApiKey';
      final response = await http.get(Uri.parse(aqiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['list'] != null && data['list'].isNotEmpty) {
          final airData = data['list'][0];
          final int apiAqi = airData['main']['aqi'];

          // Convert OpenWeatherMap AQI (1-5) to US EPA scale representative values
          int aqi;
          String aqiCategoryLabel;
          Color gaugeColor;
          switch (apiAqi) {
            case 1:
              aqi = 25;
              aqiCategoryLabel = 'Good';
              gaugeColor = Color(0xFF00E400); // Green
              break;
            case 2:
              aqi = 75;
              aqiCategoryLabel = 'Moderate';
              gaugeColor = Color(0xFFFFFF00); // Yellow
              break;
            case 3:
              aqi = 125;
              aqiCategoryLabel = 'Sensitive ';
              gaugeColor = Color(0xFFFF7E00); // Orange
              break;
            case 4:
              aqi = 175;
              aqiCategoryLabel = 'Unhealthy';
              gaugeColor = Color(0xFFFF0000); // Red
              break;
            case 5:
              aqi = 250;
              aqiCategoryLabel = 'Very Unhealthy';
              gaugeColor = Color(0xFF8F3F97); // Purple
              break;
            default:
              aqi = 0;
              aqiCategoryLabel = 'Unknown';
              gaugeColor = Color(0xFF1B998B);
          }

          // Calculate gauge progress: aqi / 500
          int gaugeProgress = ((aqi / 500) * 100).round();
          int remaining = 100 - gaugeProgress;

          // Update app state with air quality data
          FFAppState().update(() {
            FFAppState().aqiValue = aqi;
            FFAppState().aqiCategory = 'Air Quality Index';
            FFAppState().healthRisk = aqiCategoryLabel;
            FFAppState().percentages = [gaugeProgress, remaining];
            FFAppState().gaugeColor = gaugeColor;
          });

          // Parse pollutants data from OpenWeatherMap API
          final components = airData['components'];
          Map<String, String> pollutantsMap = {};

          pollutantsMap['CO'] = components['co'].toString();
          pollutantsMap['NO'] = components['no'].toString();
          pollutantsMap['NO2'] = components['no2'].toString();
          pollutantsMap['O3'] = components['o3'].toString();
          pollutantsMap['SO2'] = components['so2'].toString();
          pollutantsMap['PM2_5'] = components['pm2_5'].toString();
          pollutantsMap['PM10'] = components['pm10'].toString();
          pollutantsMap['NH3'] = components['nh3'].toString();
          pollutantsMap['AQI'] = aqi.toString();

          FFAppState().update(() {
            FFAppState().pollutants = pollutantsMap;
          });

          // Generate and save notification
          await generateNotification();
        }
      } else {
       
      }
    } catch (e) {
      
    }
  }

  // Update current date and time
  FFAppState().update(() {
    FFAppState().currentDateTime = DateFormat('MMMM d, y, h:mm a').format(DateTime.now());
  });
}
