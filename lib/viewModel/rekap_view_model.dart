import 'package:flutter/material.dart';
import 'package:godus/data/network/networks.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/models/alamat_pembeli_model.dart';
import 'package:godus/models/rekap.dart';
import 'package:godus/utils/utils.dart';
import 'package:intl/intl.dart';

class RekapViewModel with ChangeNotifier {
  // Kontroller untuk setiap inputan
  TextEditingController namaPembeliController = TextEditingController();
  TextEditingController jumlahKambingController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController dusunController = TextEditingController();
  TextEditingController rtController = TextEditingController();
  TextEditingController rwController = TextEditingController();
  TextEditingController jalanController = TextEditingController();
  TextEditingController desaController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();

  // Method untuk membersihkan kontroller saat tidak digunakan
  void disposeControllers() {
    namaPembeliController.dispose();
    jumlahKambingController.dispose();
    hargaController.dispose();
    tanggalController.dispose();
    alamatController.dispose();
    dusunController.dispose();
    rtController.dispose();
    rwController.dispose();
    jalanController.dispose();
    desaController.dispose();
    kecamatanController.dispose();
    kabupatenController.dispose();
  }

  void clearAlamatControllers() {
    alamatController.clear();
    dusunController.clear();
    rtController.clear();
    rwController.clear();
    jalanController.clear();
    desaController.clear();
    kecamatanController.clear();
    kabupatenController.clear();
  }

  void clearAllControllers() {
    namaPembeliController.clear();
    jumlahKambingController.clear();
    hargaController.clear();
    tanggalController.clear();
    alamatController.clear();
    dusunController.clear();
    rtController.clear();
    rwController.clear();
    jalanController.clear();
    desaController.clear();
    kecamatanController.clear();
    kabupatenController.clear();
  }

  Future<void> getLatlongPembeli() async {
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

    final latitude = latLng['latitude'];
    final longitude = latLng['longitude'];
    final formattedLocation = 'Lat:$latitude, Lng:$longitude';

    // Masukkan string ke dalam alamatController
    alamatController.text = formattedLocation;
    // print(latitude);
    // print(longitude);
  }

  Future<void> simpanPembeli(BuildContext context) async {
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

    final dbHelper = DatabaseHelper();
    final latitude = latLng['latitude'];
    final longitude = latLng['longitude'];
    final formattedLocation = 'Lat:$latitude, Lng:$longitude';

    // Masukkan string ke dalam alamatController
    alamatController.text = formattedLocation;

    final alamat = AlamatPembeli(
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

    final cekAlamatId = await dbHelper.getAlamatPembeliId(alamat);

    if (cekAlamatId != null) {
      final alamatId = await dbHelper.getAlamatPembeliId(alamat) ?? 0;

      // Setelah memasukkan alamat pembeli, cek apakah rekap dengan alamat tersebut sudah ada
      final rekapExists = await dbHelper.checkRekapExists(
          alamatId, namaPembeliController.text, tanggalController.text);
      if (rekapExists) {
        // Jika rekap sudah ada, tampilkan pesan kesalahan
        Utils.showErrorSnackBar(
          Overlay.of(context),
          "Pengiriman Sudah Ada",
        );
      } else {
        // Jika rekap belum ada, buat objek Rekap dan masukkan ke dalam database
        final rekap = Rekap(
          idAlamatPembeli: alamatId,
          namaPembeli: namaPembeliController.text,
          tanggalPengantaran:
              DateFormat('dd-MM-yyyy').parse(tanggalController.text),
          jumlahKambing: int.parse(jumlahKambingController.text),
          harga: double.parse(hargaController.text),
          idStatusPengantaran: 1,
        );

        await dbHelper.insertRekap(rekap);
        Utils.showSuccessSnackBar(
          Overlay.of(context),
          "Data Berhasil Disimpan",
        );
      }
      return;
    }

    await dbHelper.insertAlamatPembeli(alamat);

    final alamatId = await dbHelper.getAlamatPembeliId(alamat) ?? 0;

    // Setelah memasukkan alamat pembeli, cek apakah rekap dengan alamat tersebut sudah ada
    final rekapExists = await dbHelper.checkRekapExists(
        alamatId, namaPembeliController.text, tanggalController.text);
    if (rekapExists) {
      // Jika rekap sudah ada, tampilkan pesan kesalahan
      Utils.showErrorSnackBar(
        Overlay.of(context),
        "Pengiriman Sudah Ada",
      );
    } else {
      // Jika rekap belum ada, buat objek Rekap dan masukkan ke dalam database
      final rekap = Rekap(
        idAlamatPembeli: alamatId,
        namaPembeli: namaPembeliController.text,
        tanggalPengantaran:
            DateFormat('dd-MM-yyyy').parse(tanggalController.text),
        jumlahKambing: int.parse(jumlahKambingController.text),
        harga: double.parse(hargaController.text),
        idStatusPengantaran: 1,
      );

      await dbHelper.insertRekap(rekap);
      Utils.showSuccessSnackBar(
        Overlay.of(context),
        "Data Berhasil Disimpan",
      );
    }

    // Buat method-method lain sesuai kebutuhan aplikasi Anda
  }

  Future<List<Rekap>> getDataByMonth(int month) async {
    final dbHelper = DatabaseHelper();
    final dataByMonth = await dbHelper.getDataByMonth(month);
    print(dataByMonth);

    return dataByMonth;
  }
}
