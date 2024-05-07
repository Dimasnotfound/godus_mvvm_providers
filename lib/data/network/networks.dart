import 'package:geocoding/geocoding.dart';

class NetworkHelper {
  Future<Map<String, double?>> getLatLngFromAddress({
    required String dusun,
    required String jalan,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
  }) async {
    try {
      List<Location> locations = await locationFromAddress(
          "$jalan, $dusun,$desa, Kec. $kecamatan, Kabupaten $kabupaten, Jawa Timur");
      print(locations);

      double latitude = locations.first.latitude;
      print(latitude);

      double longitude = locations.first.longitude;
      print(longitude);

      // Mengembalikan latitude dan longitude
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      // Tangani kesalahan dan kembalikan null jika terjadi kesalahan
      print('Error: $e');
      return {'latitude': null, 'longitude': null};
    }
  }
}
