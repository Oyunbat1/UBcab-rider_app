import 'dart:math';

class GeoUtils {
  /// (Haversine formula)  2 tsegiiin hoorondoh zaig oloh;
  static double distanceKm(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Tulbur tsootsooloh heseg;
  static int estimateFare(double distanceKm) {
    const baseFare = 1500;
    const perKmRate = 1500;
    return baseFare + (distanceKm * perKmRate).round();
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
