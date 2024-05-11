import 'package:flutter/material.dart';

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
    dusunController.clear();
    rtController.clear();
    rwController.clear();
    jalanController.clear();
    desaController.clear();
    kecamatanController.clear();
    kabupatenController.clear();
  }

  void clearAllControllers(){
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

  // Buat method-method lain sesuai kebutuhan aplikasi Anda
}
