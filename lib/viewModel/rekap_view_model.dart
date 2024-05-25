// ignore_for_file: use_build_context_synchronously

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

  // SUFFIX EDIT
  TextEditingController namaPembeliEditController = TextEditingController();
  TextEditingController jumlahKambingEditController = TextEditingController();
  TextEditingController hargaEditController = TextEditingController();
  TextEditingController tanggalEditController = TextEditingController();
  TextEditingController alamatEditController = TextEditingController();
  TextEditingController dusunEditController = TextEditingController();
  TextEditingController rtEditController = TextEditingController();
  TextEditingController rwEditController = TextEditingController();
  TextEditingController jalanEditController = TextEditingController();
  TextEditingController desaEditController = TextEditingController();
  TextEditingController kecamatanEditController = TextEditingController();
  TextEditingController kabupatenEditController = TextEditingController();

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
    // print(dataByMonth);

    return dataByMonth;
  }

  Future<void> ubahStatusPengantaran(BuildContext context, int rekapId) async {
    final dbHelper = DatabaseHelper();
    final success = await dbHelper.updateStatusPengantaran(rekapId);
    if (success) {
      Utils.showSuccessSnackBar(
        Overlay.of(context),
        "Status Berhasil Diubah",
      );
    } else {
      Utils.showErrorSnackBar(
        Overlay.of(context),
        "Status Gagal Diubah",
      );
    }
  }

  String? _previousNamaPembeli = '';
  String? _previousJumlahKambing = '';
  String? _previousHarga = '';
  String? _previousTanggal = '';
  String? _previousAlamat = '';
  String? _previousDusun = '';
  String? _previousRT = '';
  String? _previousRW = '';
  String? _previousJalan = '';
  String? _previousDesa = '';
  String? _previousKecamatan = '';
  String? _previousKabupaten = '';

  Future<void> getDataPembeli(int id) async {
    Rekap? rekap = await DatabaseHelper().getRekapById(id);

    if (rekap != null) {
      AlamatPembeli? alamatPembeli =
          await DatabaseHelper().getAlamatPembeliById(rekap.idAlamatPembeli);

      // Memasukkan data dari rekap ke dalam controller edit jika tidak ada isian
      if (_previousNamaPembeli != rekap.namaPembeli) {
        namaPembeliEditController.text = rekap.namaPembeli ?? '';
        _previousNamaPembeli = rekap.namaPembeli;
      }
      if (_previousJumlahKambing != rekap.jumlahKambing.toString()) {
        jumlahKambingEditController.text = rekap.jumlahKambing.toString();
        _previousJumlahKambing = rekap.jumlahKambing.toString();
      }
      if (_previousHarga != rekap.harga.toString()) {
        hargaEditController.text = rekap.harga.toString();
        _previousHarga = rekap.harga.toString();
      }
      if (_previousTanggal != rekap.tanggalPengantaran.toString()) {
        final formattedDate = rekap.tanggalPengantaran != null
            ? DateFormat('dd-MM-yyyy').format(rekap.tanggalPengantaran!)
            : '';
        tanggalEditController.text = formattedDate;
        _previousTanggal = formattedDate;
      }

      if (alamatPembeli != null) {
        final alamatString =
            'Lat: ${alamatPembeli.latitude ?? 0}, Lng: ${alamatPembeli.longitude ?? 0}';
        if (_previousAlamat != alamatString) {
          alamatEditController.text = alamatString;
          _previousAlamat = alamatString;
        }

        // Memasukkan data dari alamat pembeli ke dalam controller edit jika tidak ada isian
        if (_previousDusun != alamatPembeli.dusun) {
          dusunEditController.text = alamatPembeli.dusun ?? '';
          _previousDusun = alamatPembeli.dusun;
        }
        if (_previousRT != alamatPembeli.rt) {
          rtEditController.text = alamatPembeli.rt ?? '';
          _previousRT = alamatPembeli.rt;
        }
        if (_previousRW != alamatPembeli.rw) {
          rwEditController.text = alamatPembeli.rw ?? '';
          _previousRW = alamatPembeli.rw;
        }
        if (_previousJalan != alamatPembeli.jalan) {
          jalanEditController.text = alamatPembeli.jalan ?? '';
          _previousJalan = alamatPembeli.jalan;
        }
        if (_previousDesa != alamatPembeli.desa) {
          desaEditController.text = alamatPembeli.desa ?? '';
          _previousDesa = alamatPembeli.desa;
        }
        if (_previousKecamatan != alamatPembeli.kecamatan) {
          kecamatanEditController.text = alamatPembeli.kecamatan ?? '';
          _previousKecamatan = alamatPembeli.kecamatan;
        }
        if (_previousKabupaten != alamatPembeli.kabupaten) {
          kabupatenEditController.text = alamatPembeli.kabupaten ?? '';
          _previousKabupaten = alamatPembeli.kabupaten;
        }
      }
    } else {
      // Penanganan jika data rekap tidak ditemukan
    }
  }

  Future<void> updateRekap(BuildContext context, int id) async {
    final networkHelper = NetworkHelper();
    final dbHelper = DatabaseHelper();

    final rekap = await dbHelper.getRekapById(id);
    if (rekap != null) {
      // Perbarui data rekap dengan nilai yang diinputkan
      rekap.namaPembeli = namaPembeliEditController.text;
      rekap.jumlahKambing = int.parse(jumlahKambingEditController.text);
      rekap.harga = double.parse(hargaEditController.text);
      rekap.tanggalPengantaran =
          DateFormat('dd-MM-yyyy').parse(tanggalEditController.text);

      // Perbarui data rekap di database
      await dbHelper.updateRekap(rekap, id);

      final latLng = await networkHelper.getLatLngFromAddress(
        dusun: dusunEditController.text,
        jalan: jalanEditController.text,
        rt: rtEditController.text,
        rw: rwEditController.text,
        desa: desaEditController.text,
        kecamatan: kecamatanEditController.text,
        kabupaten: kabupatenEditController.text,
      );

      final latitude = latLng['latitude'];
      final longitude = latLng['longitude'];
      final formattedLocation = 'Lat:$latitude, Lng:$longitude';

      // Masukkan string ke dalam alamatController
      alamatEditController.text = formattedLocation;

      final alamat = AlamatPembeli(
        id: rekap.idAlamatPembeli, // pastikan untuk menyertakan ID untuk update
        dusun: dusunEditController.text,
        rt: rtEditController.text,
        rw: rwEditController.text,
        jalan: jalanEditController.text,
        desa: desaEditController.text,
        kecamatan: kecamatanEditController.text,
        kabupaten: kabupatenEditController.text,
        latitude: latitude,
        longitude: longitude,
      );

      // Update alamat pembeli
      await dbHelper.updateAlamatPembeli(alamat);

      // Tampilkan pesan sukses
      Utils.showSuccessSnackBar(
        Overlay.of(context),
        "Data Berhasil Diubah",
      );

      // Bersihkan controller
      // clearAllEditControllers();
    }
  }

  Future<void> getLatlongPembeliEdit() async {
    final networkHelper = NetworkHelper();

    final latLng = await networkHelper.getLatLngFromAddress(
      dusun: dusunEditController.text,
      jalan: jalanEditController.text,
      rt: rtEditController.text,
      rw: rwEditController.text,
      desa: desaEditController.text,
      kecamatan: kecamatanEditController.text,
      kabupaten: kabupatenEditController.text,
    );

    final latitude = latLng['latitude'];
    final longitude = latLng['longitude'];
    final formattedLocation = 'Lat:$latitude, Lng:$longitude';

    // Masukkan string ke dalam alamatController
    alamatEditController.text = formattedLocation;

    // print(latitude);
    // print(longitude);
  }

  Future<void> hapusDataRekap(BuildContext context, int id) async {
    try {
      await DatabaseHelper().deleteRekap(id);

      // Tampilkan pesan sukses
      Utils.showSuccessSnackBar(
        Overlay.of(context),
        "Data Berhasil Dihapus",
      );
    } catch (e) {
      // Tangani kesalahan jika terjadi
      Utils.showErrorSnackBar(
        Overlay.of(context),
        "Gagal menghapus data: $e",
      );
    }
  }
}
