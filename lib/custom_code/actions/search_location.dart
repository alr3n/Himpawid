// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'get_location_and_air_quality.dart' show kGoogleApiKey;

class LocationResult {
  const LocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

/// Searches for a place by name using Google's Geocoding API (forward
/// geocoding: name -> coordinates) and returns up to 5 matching candidates,
/// for adding a Favourite location.
Future<List<LocationResult>> searchLocation(String query) async {
  if (query.trim().isEmpty) return [];

  try {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$kGoogleApiKey');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      print('Google Geocoding API error: ${response.statusCode} - ${response.body}');
      return [];
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];

    return results.take(5).map((r) {
      final result = r as Map<String, dynamic>;
      final geometry = result['geometry'] as Map<String, dynamic>;
      final location = geometry['location'] as Map<String, dynamic>;
      return LocationResult(
        name: result['formatted_address'] as String? ?? query,
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
      );
    }).toList();
  } catch (e) {
    print('Error searching location "$query": $e');
    return [];
  }
}
