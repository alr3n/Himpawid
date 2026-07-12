// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'get_location_and_air_quality.dart' show fetchAqiForCoordinates;

class CityAqi {
  const CityAqi({
    required this.city,
    required this.country,
    required this.aqi,
  });

  final String city;
  final String country;
  final int aqi;
}

/// A representative set of major world cities used for the pollution
/// ranking. Not exhaustive - chosen for global geographic spread.
const List<Map<String, dynamic>> _rankedCities = [
  {'city': 'Beijing', 'country': 'China', 'lat': 39.9042, 'lon': 116.4074},
  {'city': 'New Delhi', 'country': 'India', 'lat': 28.6139, 'lon': 77.2090},
  {'city': 'Mumbai', 'country': 'India', 'lat': 19.0760, 'lon': 72.8777},
  {'city': 'Jakarta', 'country': 'Indonesia', 'lat': -6.2088, 'lon': 106.8456},
  {'city': 'Manila', 'country': 'Philippines', 'lat': 14.5995, 'lon': 120.9842},
  {'city': 'Bangkok', 'country': 'Thailand', 'lat': 13.7563, 'lon': 100.5018},
  {'city': 'Karachi', 'country': 'Pakistan', 'lat': 24.8607, 'lon': 67.0011},
  {'city': 'Lahore', 'country': 'Pakistan', 'lat': 31.5497, 'lon': 74.3436},
  {'city': 'Lagos', 'country': 'Nigeria', 'lat': 6.5244, 'lon': 3.3792},
  {'city': 'Cairo', 'country': 'Egypt', 'lat': 30.0444, 'lon': 31.2357},
  {'city': 'Mexico City', 'country': 'Mexico', 'lat': 19.4326, 'lon': -99.1332},
  {'city': 'São Paulo', 'country': 'Brazil', 'lat': -23.5505, 'lon': -46.6333},
  {'city': 'Los Angeles', 'country': 'USA', 'lat': 34.0522, 'lon': -118.2437},
  {'city': 'New York', 'country': 'USA', 'lat': 40.7128, 'lon': -74.0060},
  {'city': 'London', 'country': 'UK', 'lat': 51.5074, 'lon': -0.1278},
  {'city': 'Paris', 'country': 'France', 'lat': 48.8566, 'lon': 2.3522},
  {'city': 'Tokyo', 'country': 'Japan', 'lat': 35.6762, 'lon': 139.6503},
  {'city': 'Seoul', 'country': 'South Korea', 'lat': 37.5665, 'lon': 126.9780},
  {'city': 'Sydney', 'country': 'Australia', 'lat': -33.8688, 'lon': 151.2093},
  {'city': 'Moscow', 'country': 'Russia', 'lat': 55.7558, 'lon': 37.6173},
];

/// Fetches the current EPA AQI for each city in [_rankedCities] (in
/// parallel) and returns them sorted worst-first, for a "most polluted
/// cities" ranking.
Future<List<CityAqi>> fetchCityRankings() async {
  final results = await Future.wait(
    _rankedCities.map((c) async {
      final aqi =
          await fetchAqiForCoordinates(c['lat'] as double, c['lon'] as double);
      return CityAqi(
        city: c['city'] as String,
        country: c['country'] as String,
        aqi: aqi,
      );
    }),
  );

  final sorted = [...results]..sort((a, b) => b.aqi.compareTo(a.aqi));
  return sorted;
}
