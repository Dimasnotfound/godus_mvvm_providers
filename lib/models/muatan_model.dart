class Muatan {
  final int id;
  final int jumlah;

  Muatan({
    required this.id,
    required this.jumlah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jumlah': jumlah,
    };
  }

  factory Muatan.fromMap(Map<String, dynamic> map) {
    return Muatan(
      id: map['id'],
      jumlah: map['jumlah'],
    );
  }
}
