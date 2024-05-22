// ignore: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'haversine_algorithm.dart'; // Sesuaikan dengan path file Haversine Anda

void main() {
  group('Haversine', () {
    test('calculateDistance returns correct distance', () {
      LatLng point1 = const LatLng(52.5200, 13.4050); // Berlin
      LatLng point2 = const LatLng(48.8566, 2.3522);  // Paris

      double distance = Haversine.calculateDistance(point1, point2);

      // Jarak seharusnya sekitar 878 km
      expect(distance, closeTo(878, 1)); // toleransi 1 km
    });

    test('sortPointsByDistance returns points sorted by distance from start', () {
      LatLng start = const LatLng(52.5200, 13.4050); // Berlin
      List<LatLng> points = [
        const LatLng(48.8566, 2.3522),  // Paris
        const LatLng(51.5074, -0.1278), // London
        const LatLng(40.7128, -74.0060) // New York
      ];

      List<LatLng> sortedPoints = Haversine.sortPointsByDistance(start, points);

      // Urutan seharusnya: Paris, London, New York
      expect(sortedPoints[0], const LatLng(48.8566, 2.3522));  // Paris
      expect(sortedPoints[1], const LatLng(51.5074, -0.1278)); // London
      expect(sortedPoints[2],  const LatLng(40.7128, -74.0060)); // New York
    });
  });
}
