import 'package:intl/intl.dart'; // Import library untuk memformat tanggal

class Rekap {
  int? id;
  int? idAlamatPembeli;
  int? idStatusPengantaran;
  String? namaPembeli;
  DateTime? tanggalPengantaran; // Ganti tipe data menjadi DateTime
  int? jumlahKambing;
  double? harga;

  Rekap({
    this.id,
    this.idAlamatPembeli,
    this.idStatusPengantaran,
    this.namaPembeli,
    this.tanggalPengantaran,
    this.jumlahKambing,
    this.harga,
  });

  // Method factory untuk membuat objek Rekap dari Map
  factory Rekap.fromMap(Map<String, dynamic> map) {
    return Rekap(
      id: map['id_rekap'],
      idAlamatPembeli: map['FK_id_alamat_pembeli'],
      idStatusPengantaran: map['FK_status_pengantaran'],
      namaPembeli: map['nama_pembeli'],
      tanggalPengantaran:
          DateFormat('dd-MM-yyyy').parse(map['tanggal_pengantaran']),
      jumlahKambing: map['jumlah_kambing'],
      harga: map['harga'],
    );
  }

  // Method untuk mengubah objek Rekap menjadi Map
  Map<String, dynamic> toMap() {
    // Format tanggal menjadi string sebelum dimasukkan ke dalam map
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(tanggalPengantaran ?? DateTime.now());

    return {
      'id_rekap': id,
      'FK_id_alamat_pembeli': idAlamatPembeli,
      'FK_status_pengantaran': idStatusPengantaran,
      'nama_pembeli': namaPembeli,
      'tanggal_pengantaran':
          formattedDate, // Masukkan tanggal yang telah diformat
      'jumlah_kambing': jumlahKambing,
      'harga': harga,
    };
  }
}
