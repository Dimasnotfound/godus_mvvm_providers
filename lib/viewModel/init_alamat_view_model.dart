// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/data/network/networks.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

    showDialog(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: Center(
            child: Text(
              "Set Lokasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300, //ubah bagian sini
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude ?? 0, longitude ?? 0),
                zoom: 17,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("alamat"),
                  position: LatLng(latitude ?? 0, longitude ?? 0),
                  draggable: true,
                  onDragEnd: (LatLng newPosition) {
                    latitude = newPosition.latitude;
                    longitude = newPosition.longitude;
                  },
                ),
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF215CA8),
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
