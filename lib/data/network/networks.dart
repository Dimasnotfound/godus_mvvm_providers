import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkHelper {
  final String apiKey = 'jA61AG11ixOJ2LPcjy4dmwCOfYjCZW4H';

  Future<Map<String, double?>> getLatLngFromAddress({
    required String dusun,
    required String jalan,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
  }) async {
    String location =
        'Dusun $dusun,$jalan,RT $rt,RW $rw,Desa $desa,Kecamatan $kecamatan,$kabupaten,Jawa Timur,Indonesia';
    String url =
        'https://www.mapquestapi.com/geocoding/v1/address?key=$apiKey&location=$location';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      if (results.isNotEmpty) {
        Map<String, dynamic> firstResult = results[0];
        List<dynamic> locations = firstResult['locations'];
        if (locations.isNotEmpty) {
          Map<String, dynamic> firstLocation = locations[0];
          Map<String, dynamic> latLng = firstLocation['latLng'];
          double latitude = latLng['lat'];
          double longitude = latLng['lng'];
          return {'latitude': latitude, 'longitude': longitude};
        }
      }
    }
    // Jika gagal mendapatkan data, kembalikan null
    return {'latitude': null, 'longitude': null};
  }
}
