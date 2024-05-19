import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/models/muatan_model.dart';
import 'package:godus/models/alamat_pembeli_model.dart';
import 'package:godus/models/rekap.dart';
import 'package:intl/intl.dart'; // Import library untuk memformat tanggal

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'goduss.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, token TEXT)',
    );
    await db.execute('''
          CREATE TABLE IF NOT EXISTS alamat_penjual(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            FK_idUser INTEGER,
            dusun TEXT,
            rt TEXT,
            rw TEXT,
            jalan TEXT,
            desa TEXT,
            kecamatan TEXT,
            kabupaten TEXT,
            latitude REAL,
            longitude REAL
          )
          ''');

    // Create Alamat Pembeli table
    await db.execute('''
          CREATE TABLE IF NOT EXISTS alamat_pembeli(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dusun TEXT,
            rt TEXT,
            rw TEXT,
            jalan TEXT,
            desa TEXT,
            kecamatan TEXT,
            kabupaten TEXT,
            latitude REAL,
            longitude REAL
          )
          ''');

    // Create Status Pengantaran table
    await db.execute('''
          CREATE TABLE IF NOT EXISTS status_pengantaran(
            id_status_pengantaran INTEGER PRIMARY KEY AUTOINCREMENT,
            status TEXT
          )
          ''');

    // Insert data ke dalam tabel status_pengantaran
    await _insertInitialStatusPengantaran(db);

    // Create Rekap table
    await db.execute('''
          CREATE TABLE IF NOT EXISTS rekap(
            id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
            FK_id_alamat_pembeli INTEGER,
            FK_status_pengantaran INTEGER,
            nama_pembeli TEXT,
            tanggal_pengantaran TEXT,
            jumlah_kambing INTEGER,
            harga REAL
          )
          ''');

    // Create Tracking table
    await db.execute('''
          CREATE TABLE IF NOT EXISTS tracking(
            id_tracking INTEGER PRIMARY KEY AUTOINCREMENT,
            FK_idUser INTEGER,
            FK_idalamat_penjual INTEGER,
            FK_idalamat_pembeli INTEGER,
            FK_idRekap INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS muatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jumlah INTEGER
          )
          ''');

    await _insertInitialUser(db);
  }

  Future<void> _insertInitialUser(Database db) async {
    await db.insert(
      'users',
      {
        'username': 'cakzul',
        'password': 'cakzul123',
        'token': '', // Awalnya kosong
      },
    );
  }

  Future<void> _insertInitialStatusPengantaran(Database db) async {
    // Insert data status_pengantaran ke dalam tabel
    await db.insert('status_pengantaran', {'status': 'on_going'});
    await db.insert('status_pengantaran', {'status': 'done'});
  }

  Future<bool> login(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (users.isNotEmpty) {
      // Generate token
      final token = const Uuid().v4();

      // Simpan token ke dalam database
      await db.update(
        'users',
        {'token': token},
        where: 'username = ?',
        whereArgs: [username],
      );

      return true;
    } else {
      return false;
    }
  }

  Future<String?> getTokenByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      columns: ['token'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (users.isNotEmpty) {
      return users.first['token'] as String?;
    } else {
      return null;
    }
  }

  Future<List<AlamatPenjual>> getAlamatPenjualList() async {
    final db = await database;
    final List<Map<String, dynamic>> alamatPenjualMaps =
        await db.query('alamat_penjual');

    return List.generate(alamatPenjualMaps.length, (i) {
      return AlamatPenjual(
        id: alamatPenjualMaps[i]['id'],
        fkIdUser: alamatPenjualMaps[i]['FK_idUser'],
        dusun: alamatPenjualMaps[i]['dusun'],
        rt: alamatPenjualMaps[i]['rt'],
        rw: alamatPenjualMaps[i]['rw'],
        jalan: alamatPenjualMaps[i]['jalan'],
        desa: alamatPenjualMaps[i]['desa'],
        kecamatan: alamatPenjualMaps[i]['kecamatan'],
        kabupaten: alamatPenjualMaps[i]['kabupaten'],
        latitude: alamatPenjualMaps[i]['latitude'],
        longitude: alamatPenjualMaps[i]['longitude'],
      );
    });
  }

  Future<AlamatPenjual?> getAlamat() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('alamat_penjual');

    if (result.isNotEmpty) {
      return AlamatPenjual.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertAlamat(AlamatPenjual alamat) async {
    final db = await database;
    Map<String, dynamic> alamatMap = alamat.toMap();
    alamatMap['FK_idUser'] = 1;
    await db.insert('alamat_penjual', alamatMap);
  }

  Future<void> updateAlamat(AlamatPenjual alamat) async {
    final db = await database;
    await db.update(
      'alamat_penjual',
      alamat.toMap(),
      where: 'id = ?',
      whereArgs: [alamat.id],
    );
  }

  Future<void> insertOrUpdateMuatan(Muatan muatan) async {
    try {
      final db = await database;
      await db.execute('''
      CREATE TABLE IF NOT EXISTS muatan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jumlah INTEGER
      )
    ''');
      await db.transaction((txn) async {
        // Cek apakah muatan sudah ada
        final existingMuatan = await txn.query(
          'muatan',
          where: 'id = 1',
        );

        if (existingMuatan.isNotEmpty) {
          // Jika muatan sudah ada, lakukan update
          await txn.update(
            'muatan',
            muatan.toMap(),
            where: 'id = 1',
          );
        } else {
          // Jika muatan belum ada, lakukan insert
          await txn.insert('muatan', muatan.toMap());
        }
      });
    } catch (e) {
      // print('Error inserting or updating muatan: $e');
      // Handle the error as needed
    }
  }

  Future<Muatan?> getMuatan() async {
    final db = await database;
    final List<Map<String, dynamic>> muatanList =
        await db.query('muatan', where: 'id = 1');

    if (muatanList.isNotEmpty) {
      return Muatan(
        id: muatanList[0]['id'],
        jumlah: muatanList[0]['jumlah'],
      );
    }
    return null;
  }

  // New method to insert Alamat Pembeli
  Future<void> insertAlamatPembeli(AlamatPembeli alamat) async {
    final db = await database;
    await db.insert('alamat_pembeli', alamat.toMap());
  }

  Future<int?> getAlamatPembeliId(AlamatPembeli alamat) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'alamat_pembeli',
      columns: ['id'],
      where:
          'dusun = ? AND jalan = ? AND rt = ? AND rw = ? AND desa = ? AND kecamatan = ? AND kabupaten = ? AND latitude = ? AND longitude = ?',
      whereArgs: [
        alamat.dusun,
        alamat.jalan,
        alamat.rt,
        alamat.rw,
        alamat.desa,
        alamat.kecamatan,
        alamat.kabupaten,
        alamat.latitude,
        alamat.longitude,
      ],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
  }

  Future<void> insertRekap(Rekap rekap) async {
    final db = await database;
    await db.insert(
      'rekap',
      rekap.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> checkRekapExists(int idAlamatPembeli, String namaPembeli,
      String tanggalPengantaran) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'rekap',
      where:
          'FK_id_alamat_pembeli = ? AND nama_pembeli = ? AND tanggal_pengantaran = ?',
      whereArgs: [idAlamatPembeli, namaPembeli, tanggalPengantaran],
    );

    return result.isNotEmpty;
  }

  Future<List<Rekap>> getDataByMonth(int month) async {
    final db = await database;

    // Format bulan dengan angka menjadi dua digit, misalnya 01 untuk Januari
    String formattedMonth = month.toString().padLeft(2, '0');

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * FROM rekap
    WHERE SUBSTR(tanggal_pengantaran, 4, 2) = ?
  ''', [formattedMonth]);

    return result.map((item) => Rekap.fromMap(item)).toList();
  }

  Future<bool> updateStatusPengantaran(int rekapId) async {
    final db = await database;
    int rowsAffected = await db.rawUpdate('''
    UPDATE rekap
    SET FK_status_pengantaran = ?
    WHERE id_rekap = ?
  ''', [2, rekapId]);

    return rowsAffected > 0;
  }

  Future<Rekap?> getRekapById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> rekapList = await db.query(
      'rekap',
      where: 'id_rekap = ?',
      whereArgs: [id],
    );

    if (rekapList.isNotEmpty) {
      return Rekap.fromMap(rekapList.first);
    }
    return null;
  }

  Future<AlamatPembeli?> getAlamatPembeliById(int? idAlamatPembeli) async {
    final db = await database;
    final List<Map<String, dynamic>> alamatPembeliList = await db.query(
      'alamat_pembeli',
      where: 'id = ?',
      whereArgs: [idAlamatPembeli],
    );

    if (alamatPembeliList.isNotEmpty) {
      return AlamatPembeli.fromMap(alamatPembeliList.first);
    }
    return null;
  }

  Future<void> updateAlamatPembeli(AlamatPembeli alamat) async {
    final db = await database;
    await db.update(
      'alamat_pembeli',
      alamat.toMap(),
      where: 'id = ?',
      whereArgs: [alamat.id],
    );
  }

  Future<void> updateRekap(Rekap rekap, int id) async {
    final db = await database;
    await db.update(
      'rekap',
      rekap.toMap(),
      where: 'id_rekap = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRekap(int id) async {
    final db = await database;
    await db.delete(
      'rekap',
      where: 'id_rekap = ?',
      whereArgs: [id],
    );
  }

  Future<List<Rekap>> getRekapByDate(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    // print(formattedDate); // Format tanggal sesuai dengan format dalam database
    final List<Map<String, dynamic>> rekapList = await db.query(
      'rekap',
      where: 'tanggal_pengantaran = ?',
      whereArgs: [formattedDate],
    );

    return List.generate(rekapList.length, (i) {
      return Rekap.fromMap(rekapList[i]);
    });
  }
}
