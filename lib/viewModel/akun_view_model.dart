import 'package:flutter/material.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/models/akun_model.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/data/network/networks.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class AkunViewModel with ChangeNotifier {
  Akun? _user;
  AlamatPenjual? _alamat;

  Akun? get user => _user;
  AlamatPenjual? get alamat => _alamat;

  String? get username => _user?.username;

  final TextEditingController dusunController = TextEditingController();
  final TextEditingController rtController = TextEditingController();
  final TextEditingController rwController = TextEditingController();
  final TextEditingController jalanController = TextEditingController();
  final TextEditingController desaController = TextEditingController();
  final TextEditingController kecamatanController = TextEditingController();
  final TextEditingController kabupatenController = TextEditingController();

  double? latitude;
  double? longitude;

  Future<void> getDataAkun() async {
    _user = await DatabaseHelper().getDataUser();
    _alamat = await DatabaseHelper().getAlamat();

    dusunController.text = _alamat?.dusun ?? '';
    rtController.text = _alamat?.rt ?? '';
    rwController.text = _alamat?.rw ?? '';
    jalanController.text = _alamat?.jalan ?? '';
    desaController.text = _alamat?.desa ?? '';
    kecamatanController.text = _alamat?.kecamatan ?? '';
    kabupatenController.text = _alamat?.kabupaten ?? '';

    notifyListeners();
  }

  void rasetAlamatControllers() {
    dusunController.text = _alamat?.dusun ?? '';
    rtController.text = _alamat?.rt ?? '';
    rwController.text = _alamat?.rw ?? '';
    jalanController.text = _alamat?.jalan ?? '';
    desaController.text = _alamat?.desa ?? '';
    kecamatanController.text = _alamat?.kecamatan ?? '';
    kabupatenController.text = _alamat?.kabupaten ?? '';
  }

  @override
  void dispose() {
    dusunController.dispose();
    rtController.dispose();
    rwController.dispose();
    jalanController.dispose();
    desaController.dispose();
    kecamatanController.dispose();
    kabupatenController.dispose();
    super.dispose();
  }

  Future<void> getLatLng(BuildContext context) async {
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
    // print('+++++++++++++++++++++++++++++++++++++++++++++++');
  }

  Future<void> updateAlamatPenjual(BuildContext context) async {
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
      await getDataAkun();
    }

    notifyListeners();
  }
}
