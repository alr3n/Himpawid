import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'get_location_and_air_quality.dart' show epaCategory;

/// Saves a notification document reflecting the just-fetched AQI reading.
/// Skips silently if there's no valid reading yet (aqiValue == 0) or the
/// last fetch failed (aqiError set) - a stale/failed reading should never
/// produce a notification claiming to be current.
Future<void> generateNotification() async {
  final firestore = FirebaseFirestore.instance;

  final aqiValue = FFAppState().aqiValue;
  final locationName = FFAppState().currentLocation;

  if (aqiValue == 0 || FFAppState().aqiError.isNotEmpty) {
    return;
  }

  // EPA AQI (0-500, higher = worse) - the same scale used everywhere
  // else in the app. This used to duplicate a stale Google Universal AQI
  // (0-100, higher = cleaner) labeling table, which after the OpenWeather
  // migration meant a Hazardous reading (e.g. 400) was mislabeled
  // "Excellent, safe to be outdoors" - the exact opposite of reality.
  final aqiLabel = epaCategory(aqiValue);
  final String comment;
  if (aqiValue <= 50) {
    comment = 'Air quality is great today. Safe to be outdoors.';
  } else if (aqiValue <= 100) {
    comment = 'Air quality is acceptable for most people.';
  } else if (aqiValue <= 150) {
    comment =
        'Sensitive groups should limit prolonged outdoor exertion today.';
  } else if (aqiValue <= 200) {
    comment = 'Everyone may begin to experience health effects. Consider '
        'a mask outdoors.';
  } else if (aqiValue <= 300) {
    comment = 'Health alert: avoid prolonged outdoor exertion.';
  } else {
    comment = 'Health emergency. Avoid outdoor activity.';
  }

  final notificationData = {
    'title': 'Himpawid System',
    'aqiLevel': aqiValue,
    'aqiLabel': aqiLabel,
    'comment': comment,
    'locationName': locationName.isNotEmpty ? locationName : 'Current Location',
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await firestore.collection('notifications').add(notificationData);
  } catch (e) {
    print('[AQI FLOW] Error saving notification: $e');
  }
}
