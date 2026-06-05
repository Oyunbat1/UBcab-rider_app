import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rider_app/core/constants/api_constants.dart';

/// Google Directions API-аас буцаасан замын мэдээлэл.

class RouteInfo {
  final double distanceKm;

  final int durationMinutes;

  /// Замыг газрын зураг дээр зурах polyline цэгүүд.
  final List<LatLng> points;

  final String distanceText;

  final String durationText;

  RouteInfo({required this.distanceKm, required this.durationMinutes, required this.points, required this.distanceText, required this.durationText});
}

class DirectionsService {
  final http.Client _client;

  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  Future<RouteInfo?> getRoute(LatLng origin, LatLng destination) async {
    final uri = Uri.parse(ApiConstants.directionsBaseUrl).replace(
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'alternatives': 'true',
        'key': ApiConstants.googleMapsApiKey,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      // status != 'OK' bol (ж: ZERO_RESULTS, REQUEST_DENIED) zam baikhgui.
      if (data['status'] != 'OK') return null;

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      Map<String, dynamic>? bestRoute;
      Map<String, dynamic>? bestLeg;
      double bestMeters = double.infinity;
      for (final r in routes) {
        final rt = r as Map<String, dynamic>;
        final legs = rt['legs'] as List?;
        if (legs == null || legs.isEmpty) continue;
        final leg = legs.first as Map<String, dynamic>;
        final meters = (leg['distance']['value'] as num).toDouble();
        if (meters < bestMeters) {
          bestMeters = meters;
          bestRoute = rt;
          bestLeg = leg;
        }
      }
      if (bestRoute == null || bestLeg == null) return null;

      final distance = bestLeg['distance'] as Map<String, dynamic>;
      final duration = bestLeg['duration'] as Map<String, dynamic>;

      final distanceMeters = (distance['value'] as num).toDouble();
      final durationSeconds = (duration['value'] as num).toInt();

      final encoded = (bestRoute['overview_polyline'] as Map<String, dynamic>)['points'] as String;

      return RouteInfo(
        distanceKm: distanceMeters / 1000.0,
        durationMinutes: (durationSeconds / 60).round(),
        points: _decodePolyline(encoded),
        distanceText: (distance['text'] as String?) ?? '',
        durationText: (duration['text'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
