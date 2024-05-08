import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/models/muatan_model.dart';
import 'package:godus/utils/utils.dart';

class TrackingViewModel with ChangeNotifier {
  // Mengimpor ChangeNotifier dari provider

  LatLng? _googlePlexLatLng;
  Muatan? _muatan;

  Muatan createMuatan(int jumlah) {
    // Buat objek Muatan
    return Muatan(
      id: 1, // ID tetap 1 sesuai kebutuhan
      jumlah: jumlah,
    );
  }

  Future<void> insertOrUpdateMuatan(Muatan muatan, BuildContext context) async {
    final db = DatabaseHelper();
    await db.insertOrUpdateMuatan(muatan);
    Utils.showSuccessSnackBar(
      Overlay.of(context),
      "Data Berhasil Ditambahkan",
    );
    await fetchMuatan();
  }

  Future<void> fetchMuatan() async {
    final db = DatabaseHelper();
    _muatan = await db.getMuatan();
    print(_muatan); // Gunakan metode getMuatan dari DatabaseHelper
    notifyListeners();
  }

  Muatan? get muatan => _muatan;

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
