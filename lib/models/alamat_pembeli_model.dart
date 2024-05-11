class AlamatPembeli {
  int? id;
  String? dusun;
  String? rt;
  String? rw;
  String? jalan;
  String? desa;
  String? kecamatan;
  String? kabupaten;
  double? latitude;
  double? longitude;

  AlamatPembeli({
    this.id,
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

  factory AlamatPembeli.fromJson(Map<String, dynamic> json) {
    return AlamatPembeli(
      id: json['id'],
      dusun: json['dusun'],
      rt: json['rt'],
      rw: json['rw'],
      jalan: json['jalan'],
      desa: json['desa'],
      kecamatan: json['kecamatan'],
      kabupaten: json['kabupaten'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
}
