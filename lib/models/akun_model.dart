class Akun {
  String? token;
  final int id;
  final String username;
  final String password;

  Akun({
    required this.id,
    required this.username,
    required this.password,
    this.token,
  });

  factory Akun.fromJson(Map<String, dynamic> json) {
    return Akun(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      token: json['token'],
    );
  }

  factory Akun.fromMap(Map<String, dynamic> map) {
    return Akun(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      token: map['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    data['token'] = token;
    return data;
  }
}
