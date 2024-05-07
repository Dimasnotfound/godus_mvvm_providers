import 'package:flutter/material.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/data/network/networks.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/utils/utils.dart';

class AlamatViewModel with ChangeNotifier {
  late TextEditingController dusunController = TextEditingController();
  late TextEditingController rtController = TextEditingController();
  late TextEditingController rwController = TextEditingController();
  late TextEditingController jalanController = TextEditingController();
  late TextEditingController desaController = TextEditingController();
  late TextEditingController kecamatanController = TextEditingController();
  late TextEditingController kabupatenController = TextEditingController();

  double? latitude;
  double? longitude;

  Future<void> fetchDataAndFillTextControllers() async {
    final List<AlamatPenjual> alamatPenjualList =
        await DatabaseHelper().getAlamatPenjualList();
    if (alamatPenjualList.isNotEmpty) {
      final alamatPenjual = alamatPenjualList[0];
      if (dusunController.text.isEmpty) {
        dusunController.text = alamatPenjual.dusun ?? '';
      }
      if (rtController.text.isEmpty) {
        rtController.text = alamatPenjual.rt ?? '';
      }
      if (rwController.text.isEmpty) {
        rwController.text = alamatPenjual.rw ?? '';
      }
      if (jalanController.text.isEmpty) {
        jalanController.text = alamatPenjual.jalan ?? '';
      }
      if (desaController.text.isEmpty) {
        desaController.text = alamatPenjual.desa ?? '';
      }
      if (kecamatanController.text.isEmpty) {
        kecamatanController.text = alamatPenjual.kecamatan ?? '';
      }
      if (kabupatenController.text.isEmpty) {
        kabupatenController.text = alamatPenjual.kabupaten ?? '';
      }
    }
  }

  Future<void> saveOrUpdateAlamat(BuildContext context) async {
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
      return;
    }

    final networkHelper = NetworkHelper();
    final latLng = await networkHelper.getLatLngFromAddress(
      dusun: dusunController.text,
      jalan: jalanController.text,
      rt: rtController.text,
      rw: rwController.text,
      desa: desaController.text,
      kecamatan: kecamatanController.text,
      kabupaten: kabupatenController.text,
    );

    latitude = latLng['latitude'];
    longitude = latLng['longitude'];

    final dbHelper = DatabaseHelper();
    final alamat = AlamatPenjual(
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

    final existingAlamat = await dbHelper.getAlamat();
    if (existingAlamat == null) {
      await dbHelper.insertAlamat(alamat);
    } else {
      alamat.id = existingAlamat.id;
      await dbHelper.updateAlamat(alamat);
    }

    Utils.showSuccessSnackBar(
      Overlay.of(context),
      "Data Berhasil Disimpan",
    );

    Navigator.pushNamed(context, RouteNames.home);
  }
}
