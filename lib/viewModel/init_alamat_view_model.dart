import 'package:flutter/material.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/data/network/networks.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/utils/utils.dart';

class AlamatViewModel with ChangeNotifier {
  TextEditingController dusunController = TextEditingController();
  TextEditingController rtController = TextEditingController();
  TextEditingController rwController = TextEditingController();
  TextEditingController jalanController = TextEditingController();
  TextEditingController desaController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();

  void fetchDataAndFillTextControllers() async {
    final List<AlamatPenjual> alamatPenjualList =
        await DatabaseHelper().getAlamatPenjualList();
    if (alamatPenjualList.isNotEmpty) {
      dusunController.text = alamatPenjualList[0].dusun ?? '';
      rtController.text = alamatPenjualList[0].rt ?? '';
      rwController.text = alamatPenjualList[0].rw ?? '';
      jalanController.text = alamatPenjualList[0].jalan ?? '';
      desaController.text = alamatPenjualList[0].desa ?? '';
      kecamatanController.text = alamatPenjualList[0].kecamatan ?? '';
      kabupatenController.text = alamatPenjualList[0].kabupaten ?? '';
    } else {
      // Set default values or leave them empty
    }
  }
double? latitude;
  double? longitude;

  void saveOrUpdateAlamat(BuildContext context) async {
  // Validasi input
   if (dusunController.text.isEmpty ||
      rtController.text.isEmpty ||
      rwController.text.isEmpty ||
      jalanController.text.isEmpty ||
      desaController.text.isEmpty ||
      kecamatanController.text.isEmpty) {
    Utils.showErrorSnackBar(
      Overlay.of(context),
      "Alamat Tidak Boleh Kosong",
    );
    return; // Hentikan eksekusi jika ada input yang kosong
  }

  NetworkHelper networkHelper = NetworkHelper();
  Map<String, double?> latLng = await networkHelper.getLatLngFromAddress(
    dusun: dusunController.text,
    jalan: jalanController.text,
    rt: rtController.text,
    rw: rwController.text,
    desa: desaController.text,
    kecamatan: kecamatanController.text,
    kabupaten: kabupatenController.text,
  );

  if (latLng['latitude'] != null && latLng['longitude'] != null) {
    latitude = latLng['latitude'];
    longitude = latLng['longitude'];
  }

  DatabaseHelper dbHelper = DatabaseHelper();
  AlamatPenjual alamat = AlamatPenjual(
    dusun: dusunController.text,
    rt: rtController.text,
    rw: rwController.text,
    jalan: jalanController.text,
    desa: desaController.text,
    kecamatan: kecamatanController.text,
    kabupaten: kabupatenController.text,
    latitude: latitude,
    longitude: longitude,
  );

  // Cek apakah data alamat sudah ada dalam database
  AlamatPenjual? existingAlamat = await dbHelper.getAlamat();
  if (existingAlamat == null) {
    // Jika belum ada, maka lakukan penyimpanan data
    await dbHelper.insertAlamat(alamat);
  } else {
    // Jika sudah ada, maka lakukan pembaruan data
    alamat.id = existingAlamat.id;
    await dbHelper.updateAlamat(alamat);
  }

  Utils.showSuccessSnackBar(
  Overlay.of(context),
  "Data Berhasil Disimpan",
);

  // Arahkan pengguna ke halaman beranda
  Navigator.pushNamed(context, RouteNames.home);
}

}
