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

  // Determine AQI label and comment based on the Universal AQI value
  // (Google Air Quality API: 0-100, HIGHER means CLEANER air).
  String aqiLabel;
  String comment;
  if (aqiValue >= 80) {
    aqiLabel = 'Excellent';
    comment = 'Air quality is excellent, safe to be outdoors';
  } else if (aqiValue >= 60) {
    aqiLabel = 'Good';
    comment = 'Air quality is acceptable for most people';
  } else if (aqiValue >= 40) {
    aqiLabel = 'Moderate';
    comment = 'People with health conditions should limit strenuous activities';
  } else if (aqiValue >= 20) {
    aqiLabel = 'Low';
    comment = 'Limit outdoor activities';
  } else {
    aqiLabel = 'Poor';
    comment = 'Avoid going outside if possible';
  }

  // Create notification data with new structure
  final notificationData = {
    'title': 'Himpawid System',
    'aqiLevel': aqiValue,
    'aqiLabel': aqiLabel,
    'comment': comment,
    'locationName': locationName.isNotEmpty ? locationName : 'Current Location',
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
