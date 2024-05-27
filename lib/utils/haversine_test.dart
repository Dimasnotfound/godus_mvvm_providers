// ignore: depend_on_referenced_packages
// ignore_for_file: avoid_print

// ignore: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'haversine_algorithm.dart'; // Sesuaikan dengan path file Haversine Anda

void main() {
  group('Haversine', () {
    test('calculateDistance returns correct distance', () {
      LatLng point1 =
          const LatLng(-8.161202259342332, 113.69140741383866); // rumah cakzul
      LatLng point2 = const LatLng(-8.259043, 113.649244); // jenggawah

      double distance = Haversine.calculateDistance(point1, point2);

      // Jarak seharusnya sekitar 11 km
      print('Distance: $distance km');
      expect(distance, closeTo(11, 1)); // toleransi 1 km
    });

    test('sortPointsByDistance returns points sorted by distance from start',
        () {
      LatLng start =
          const LatLng(-8.161202259342332, 113.69140741383866); // rumah cakzul
      List<LatLng> points = [
        const LatLng(-8.044278, 113.779831), // maesan
        const LatLng(-8.210922, 113.771900), // mumbulsari
        const LatLng(-8.203050, 113.571440) // bangsalsari
      ];

      List<LatLng> sortedPoints = Haversine.sortPointsByDistance(start, points);

      for (LatLng point in sortedPoints) {
        double distance = Haversine.calculateDistance(start, point);
        print(
            'Point: ${point.latitude}, ${point.longitude} -> Distance: $distance km');
      }

      // Urutan seharusnya: Maesan, Mumbulsari, Bangsalsari
      expect(
          sortedPoints[0], const LatLng(-8.210922, 113.771900)); // Mumbulsari
      expect(
          sortedPoints[1], const LatLng(-8.203050, 113.571440)); // Bangsalsari
      expect(sortedPoints[2], const LatLng(-8.044278, 113.779831)); // Maesan
    });
  });
}
