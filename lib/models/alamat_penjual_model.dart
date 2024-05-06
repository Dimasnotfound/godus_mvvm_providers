class AlamatPenjual {
  int? id;
  int? fkIdUser;
  String? dusun;
  String? rt;
  String? rw;
  String? jalan;
  String? desa;
  String? kecamatan;
  String? kabupaten;
  double? latitude;
  double? longitude;

  AlamatPenjual({
    this.id,
    this.fkIdUser,
    this.dusun,
    this.rt,
    this.rw,
    this.jalan,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.latitude,
    this.longitude,
  });

  // Method untuk mengonversi objek AlamatPenjual menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'FK_idUser': fkIdUser,
      'dusun': dusun,
      'rt': rt,
      'rw': rw,
      'jalan': jalan,
      'desa': desa,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
// Metode untuk mengonversi Map menjadi objek AlamatPenjual
  factory AlamatPenjual.fromMap(Map<String, dynamic> map) {
    return AlamatPenjual(
      id: map['id'] as int?,
      fkIdUser: map['FK_idUser'] as int?,
      dusun: map['dusun'] as String?,
      rt: map['rt'] as String?,
      rw: map['rw'] as String?,
      jalan: map['jalan'] as String?,
      desa: map['desa'] as String?,
      kecamatan: map['kecamatan'] as String?,
      kabupaten: map['kabupaten'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }
  
}
