import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/models/alamat_penjual_model.dart'; // Memperbaiki impor DatabaseHelper

class TrackingViewModel with ChangeNotifier {
  // Mengimpor ChangeNotifier dari provider

  LatLng? _googlePlexLatLng;

  Future<void> fetchGooglePlexLatLng() async {
    final alamatPenjualList = await DatabaseHelper().getAlamatPenjualList();
    if (alamatPenjualList.isNotEmpty) {
      final AlamatPenjual alamatPenjual = alamatPenjualList.first;
      final latitude = alamatPenjual.latitude;
      final longitude = alamatPenjual.longitude;
      // print(latitude);
      // print(longitude);


      // Menangani nilai null dengan nilai default (0)
      final defaultLatitude = latitude ?? 0;
      final defaultLongitude = longitude ?? 0;

      _googlePlexLatLng = LatLng(defaultLatitude, defaultLongitude);
      notifyListeners();
    }
  }

  LatLng? get googlePlexLatLng => _googlePlexLatLng;
}
