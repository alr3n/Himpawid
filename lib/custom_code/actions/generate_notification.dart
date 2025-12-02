import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

Future<void> generateNotification() async {
  final firestore = FirebaseFirestore.instance;

  // Get current AQI data from app state
  final aqiValue = FFAppState().aqiValue;
  final aqiCategory = FFAppState().aqiCategory;
  final healthRisk = FFAppState().healthRisk;
  final locationName = FFAppState().currentLocation;

  // Skip if no AQI data available
  if (aqiValue == 0 || aqiCategory.isEmpty) {
    return;
  }
  
  // Generate title based on AQI category
  String title;
  switch (aqiCategory.toLowerCase()) {
    case 'good':
      title = 'Good Air Quality';
      break;
    case 'moderate':
      title = 'Moderate Air Quality';
      break;
    case 'unhealthy for sensitive groups':
      title = 'Unhealthy for Sensitive Groups';
      break;
    case 'unhealthy':
      title = 'Unhealthy Air Levels';
      break;
    case 'very unhealthy':
      title = 'Very Unhealthy Air Levels';
      break;
    case 'hazardous':
      title = 'Hazardous Air Quality';
      break;
    default:
      title = 'Air Quality Update';
  }

  // Generate subtitle based on health advice
  String subtitle;
  if (healthRisk.isNotEmpty && healthRisk != 'Unknown') {
    subtitle = healthRisk;
  } else {
    // Fallback subtitles based on AQI category
    switch (aqiCategory.toLowerCase()) {
      case 'good':
        subtitle = 'Air quality is Good (AQI $aqiValue). Enjoy the clean air!';
        break;
      case 'moderate':
        subtitle = 'Air quality is Moderate (AQI $aqiValue). Unusually sensitive people should consider reducing prolonged or heavy exertion.';
        break;
      case 'unhealthy for sensitive groups':
        subtitle = 'Air quality is Unhealthy for Sensitive Groups (AQI $aqiValue). Children, the elderly, and people with respiratory conditions should limit outdoor activity.';
        break;
      case 'unhealthy':
        subtitle = 'Air quality is Unhealthy (AQI $aqiValue). Everyone may begin to experience health effects; members of sensitive groups may experience more serious effects.';
        break;
      case 'very unhealthy':
        subtitle = 'Air quality is Very Unhealthy (AQI $aqiValue). Health alert: everyone may experience more serious health effects.';
        break;
      case 'hazardous':
        subtitle = 'Air quality is Hazardous (AQI $aqiValue). Health warning of emergency conditions. The entire population is more likely to be affected.';
        break;
      default:
        subtitle = 'Current AQI: $aqiValue. Check local air quality guidelines.';
    }
  }

  // Create notification data
  final notificationData = {
    'title': title,
    'subtitle': subtitle,
    'aqiValue': aqiValue,
    'locationName': locationName.isNotEmpty ? locationName : 'Unknown Location',
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    // Save to Firestore
    await firestore.collection('notifications').add(notificationData);
  } catch (e) {
    // Handle error silently for now
    print('Error saving notification: $e');
  }
}
