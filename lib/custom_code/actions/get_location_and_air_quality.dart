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
    final String aqiApiKey = 'YOUR_OPENWEATHER_API_KEY'; // Replace with actual OpenWeather API key
    final double lat = FFAppState().latitude;
    final double lon = FFAppState().longitude;

    try {
      final aqiUrl = 'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$aqiApiKey';
      final response = await http.get(Uri.parse(aqiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['list'] != null && data['list'].isNotEmpty) {
          final airQualityData = data['list'][0];
          final components = airQualityData['components'] ?? {};
          final main = airQualityData['main'] ?? {};

          // Get AQI value (OpenWeather uses 1-5 scale, convert to 0-500 scale approximately)
          final aqiRaw = main['aqi'] ?? 1;
          int aqi = 0;
          switch (aqiRaw) {
            case 1:
              aqi = 25; // Good
              break;
            case 2:
              aqi = 75; // Fair
              break;
            case 3:
              aqi = 125; // Moderate
              break;
            case 4:
              aqi = 175; // Poor
              break;
            case 5:
              aqi = 250; // Very Poor
              break;
            default:
              aqi = 0;
          }

          // Determine AQI category based on value
          String aqiCategoryLabel = 'Unknown';
          if (aqi <= 50) {
            aqiCategoryLabel = 'Good';
          } else if (aqi <= 100) {
            aqiCategoryLabel = 'Moderate';
          } else if (aqi <= 150) {
            aqiCategoryLabel = 'Unhealthy for Sensitive Groups';
          } else if (aqi <= 200) {
            aqiCategoryLabel = 'Unhealthy';
          } else if (aqi <= 300) {
            aqiCategoryLabel = 'Very Unhealthy';
          } else {
            aqiCategoryLabel = 'Hazardous';
          }

          // Calculate gauge progress: aqi / 500
          int gaugeProgress = ((aqi / 500) * 100).round();
          int remaining = 100 - gaugeProgress;

          // Determine gauge color based on AQI
          Color gaugeColor;
          if (aqi <= 50) {
            gaugeColor = Color(0xFF00E400); // Green for Good
          } else if (aqi <= 100) {
            gaugeColor = Color(0xFFFFFF00); // Yellow for Moderate
          } else if (aqi <= 150) {
            gaugeColor = Color(0xFFFF7E00); // Orange for Unhealthy for Sensitive Groups
          } else if (aqi <= 200) {
            gaugeColor = Color(0xFFFF0000); // Red for Unhealthy
          } else if (aqi <= 300) {
            gaugeColor = Color(0xFF8F3F97); // Purple for Very Unhealthy
          } else {
            gaugeColor = Color(0xFF7E0023); // Maroon for Hazardous
          }

          // Update app state with air quality data
          FFAppState().update(() {
            FFAppState().aqiValue = aqi;
            FFAppState().aqiCategory = 'Air Quality Index';
            FFAppState().healthRisk = aqiCategoryLabel;
            FFAppState().percentages = [gaugeProgress, remaining];
            FFAppState().gaugeColor = gaugeColor;
          });

          // Parse pollutants data from components
          FFAppState().update(() {
            FFAppState().pollutants = {
              'AQI': aqi.toDouble(),
              'CO': components['co']?.toDouble() ?? 0.0,
              'NO': components['no']?.toDouble() ?? 0.0,
              'NO2': components['no2']?.toDouble() ?? 0.0,
              'O3': components['o3']?.toDouble() ?? 0.0,
              'SO2': components['so2']?.toDouble() ?? 0.0,
              'PM2_5': components['pm2_5']?.toDouble() ?? 0.0,
              'PM10': components['pm10']?.toDouble() ?? 0.0,
              'NH3': components['nh3']?.toDouble() ?? 0.0,
            };
            // Set individual pollutant values
            FFAppState().coValue = components['co']?.toDouble() ?? 0.0;
            FFAppState().noValue = components['no']?.toDouble() ?? 0.0;
            FFAppState().no2Value = components['no2']?.toDouble() ?? 0.0;
            FFAppState().o3Value = components['o3']?.toDouble() ?? 0.0;
            FFAppState().so2Value = components['so2']?.toDouble() ?? 0.0;
            FFAppState().pm25Value = components['pm2_5']?.toDouble() ?? 0.0;
            FFAppState().pm10Value = components['pm10']?.toDouble() ?? 0.0;
            FFAppState().nh3Value = components['nh3']?.toDouble() ?? 0.0;
          });

          // Generate and save notification
          await generateNotification();
        }
      } else {
        // API call failed, use mock data for demonstration
        int mockAqi = 45; // Example: Good air quality
        String mockCategory = 'Good';
        int gaugeProgress = ((mockAqi / 500) * 100).round();
        int remaining = 100 - gaugeProgress;
        Color gaugeColor = Color(0xFF00E400); // Green

        FFAppState().update(() {
          FFAppState().aqiValue = mockAqi;
          FFAppState().aqiCategory = 'Air Quality Index';
          FFAppState().healthRisk = mockCategory;
          FFAppState().percentages = [gaugeProgress, remaining];
          FFAppState().gaugeColor = gaugeColor;
        });

        // Mock pollutants data
        FFAppState().update(() {
          FFAppState().pollutants = {
            'AQI': mockAqi.toDouble(),
            'CO': 300.0,
            'NO': 5.0,
            'NO2': 15.0,
            'O3': 25.0,
            'SO2': 8.0,
            'PM2_5': 12.0,
            'PM10': 20.0,
            'NH3': 2.0,
          };
          FFAppState().coValue = 300.0;
          FFAppState().noValue = 5.0;
          FFAppState().no2Value = 15.0;
          FFAppState().o3Value = 25.0;
          FFAppState().so2Value = 8.0;
          FFAppState().pm25Value = 12.0;
          FFAppState().pm10Value = 20.0;
          FFAppState().nh3Value = 2.0;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  // Update current date and time
  FFAppState().update(() {
    FFAppState().currentDateTime = DateFormat('MMMM d, y, h:mm a').format(DateTime.now());
  });
}
