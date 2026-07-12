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

import '/flutter_flow/flutter_flow_map.dart' show kMapTilerApiKey;

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

/// Thrown when the Geocoding API itself failed (bad key, quota, malformed
/// request, network error) - distinct from a search that ran fine but
/// genuinely matched nothing, so the UI can tell "try a different search"
/// apart from "something is actually broken".
class LocationSearchException implements Exception {
  const LocationSearchException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Searches for a place by name using MapTiler's Geocoding API (forward
/// geocoding: name -> coordinates) and returns up to 5 matching
/// candidates - cities, municipalities, provinces, or any other place the
/// geocoder resolves - for adding a Favourite location.
///
/// Unlike Google's Geocoding API, MapTiler reports real failures (bad key,
/// quota, malformed request) via the HTTP status code itself rather than
/// a 200-with-error-in-body quirk, so a plain status-code check is
/// sufficient here to tell a genuine zero-result search apart from the
/// request having failed outright.
Future<List<LocationResult>> searchLocation(String query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  print('[SEARCH] Searching for "$trimmed"');

  final url = Uri.parse(
      'https://api.maptiler.com/geocoding/${Uri.encodeComponent(trimmed)}.json?key=$kMapTilerApiKey');

  http.Response response;
  try {
    response = await http.get(url);
  } catch (e) {
    print('[SEARCH] Network error: $e');
    throw LocationSearchException(
        'Could not reach the search service. Check your connection.');
  }

  print('[SEARCH] HTTP ${response.statusCode}');

  if (response.statusCode != 200) {
    // MapTiler returns a plain-text error body (e.g. "Invalid key...") on
    // failure rather than JSON, so surface it as-is when present.
    final body = response.body.trim();
    throw LocationSearchException(body.isNotEmpty
        ? body
        : 'Search failed (HTTP ${response.statusCode}).');
  }

  final Map<String, dynamic> data;
  try {
    data = json.decode(response.body) as Map<String, dynamic>;
  } catch (e) {
    print('[SEARCH] Could not parse response: $e');
    throw const LocationSearchException('Search returned an invalid response.');
  }

  final features = data['features'] as List<dynamic>? ?? [];
  final parsed = features.take(5).map((f) {
    final feature = f as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    return LocationResult(
      name: feature['place_name'] as String? ?? trimmed,
      latitude: (coordinates[1] as num).toDouble(),
      longitude: (coordinates[0] as num).toDouble(),
    );
  }).toList();

  print('[SEARCH] ${parsed.length} result(s)');
  return parsed;
}
