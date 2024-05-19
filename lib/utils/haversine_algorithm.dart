import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class Haversine {
  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  static double calculateDistance(LatLng start, LatLng end) {
    final lat1 = _toRadians(start.latitude);
    final lon1 = _toRadians(start.longitude);
    final lat2 = _toRadians(end.latitude);
    final lon2 = _toRadians(end.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);

    final c = 2 * asin(sqrt(a));

    const earthRadius = 6371; // Earth radius in kilometers
    return earthRadius * c;
  }

  static List<LatLng> sortPointsByDistance(LatLng start, List<LatLng> points) {
    points.sort((a, b) {
      final distA = calculateDistance(start, a);
      final distB = calculateDistance(start, b);
      return distA.compareTo(distB);
    });
    return points;
  }
}
