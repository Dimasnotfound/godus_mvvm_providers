// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:godus/models/alamat_penjual_model.dart';
import 'package:godus/models/alamat_pembeli_model.dart';
import 'package:godus/models/muatan_model.dart';
import 'package:godus/models/rekap.dart';
import 'package:godus/utils/utils.dart';
import 'package:godus/data/network/network_polyline.dart';
import 'package:godus/utils/haversine_algorithm.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:intl/intl.dart';
// import 'package:path/path.dart';

class TrackingViewModel with ChangeNotifier {
  LatLng? _googlePlexLatLng;
  Muatan? _muatan;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  DateTime? _selectedDate;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Muatan createMuatan(int jumlah) {
    return Muatan(
      id: 1,
      jumlah: jumlah,
    );
  }

  Future<void> insertOrUpdateMuatan(Muatan muatan, BuildContext context) async {
    final db = DatabaseHelper();
    await db.insertOrUpdateMuatan(muatan);
    Utils.showSuccessSnackBar(
      Overlay.of(context),
      "Data Berhasil Ditambahkan",
    );
    await fetchMuatan();
  }

  Future<void> fetchMuatan() async {
    final db = DatabaseHelper();
    _muatan = await db.getMuatan();
    notifyListeners();
  }

  Muatan? get muatan => _muatan;

  Future<void> fetchGooglePlexLatLng() async {
    final alamatPenjualList = await DatabaseHelper().getAlamatPenjualList();
    if (alamatPenjualList.isNotEmpty) {
      final AlamatPenjual alamatPenjual = alamatPenjualList.first;
      final latitude = alamatPenjual.latitude;
      final longitude = alamatPenjual.longitude;

      final defaultLatitude = latitude ?? 0;
      final defaultLongitude = longitude ?? 0;

      _googlePlexLatLng = LatLng(defaultLatitude, defaultLongitude);

      // Tambahkan marker tetap di posisi googlePlexLatLng
      _markers.add(
        Marker(
          markerId: const MarkerId("googlePlexMarker"),
          position: _googlePlexLatLng!,
        ),
      );

      notifyListeners();
    }
  }

  LatLng? get googlePlexLatLng => _googlePlexLatLng;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  DateTime? get selectedDate => _selectedDate;
  CustomInfoWindowController get customInfoWindowController =>
      _customInfoWindowController;

  void clearMarkers() {
    _markers.clear();
    if (_googlePlexLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("googlePlexMarker"),
          position: _googlePlexLatLng!,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> fetchRekapByDate(BuildContext context, DateTime date) async {
    _selectedDate = date;
    clearMarkers();
    _polylines.clear();
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final List<Rekap>? rekapList = await DatabaseHelper().getRekapByDate(date);
    List<LatLng> points = [];

    if (rekapList != null && rekapList.isNotEmpty) {
      for (Rekap rekap in rekapList) {
        final int? idAlamatPembeli = rekap.idAlamatPembeli;
        if (idAlamatPembeli != null) {
          final AlamatPembeli? alamatPembeli =
              await DatabaseHelper().getAlamatPembeliById(idAlamatPembeli);
          if (alamatPembeli != null) {
            final LatLng position = LatLng(
                alamatPembeli.latitude ?? 0, alamatPembeli.longitude ?? 0);
            points.add(position);
          }
        }
      }
    }

    // Urutkan points berdasarkan jarak dari _googlePlexLatLng
    points = Haversine.sortPointsByDistance(_googlePlexLatLng!, points);

    if (points.isNotEmpty) {
      LatLng startPoint = _googlePlexLatLng!;
      LatLng currentPoint = startPoint;

      // Variabel untuk menyimpan jarak dan waktu kumulatif
      double cumulativeDistance = 0.0;
      double cumulativeDuration = 0.0;

      for (int i = 0; i < points.length; i++) {
        LatLng nextPoint = points[i];

        // Menggunakan DirectionsRepository untuk mendapatkan jarak dan waktu antara currentPoint dan nextPoint
        final directions = await DirectionsRepository().getDirections(
          origin: currentPoint,
          destination: nextPoint,
        );
        // print('============================================');
        // print(directions?.totalDuration);

        if (directions != null) {
          // Tambahkan jarak dan waktu ke kumulatif
          cumulativeDistance += _parseDistance(directions.totalDistance);
          cumulativeDuration += _parseDuration(directions.totalDuration);

          Rekap rekap = rekapList![i];

          // Tambahkan marker dengan jarak dan waktu kumulatif
          addMarker(
            context,
            nextPoint,
            rekap,
            _formatDistance(cumulativeDistance),
            _formatDuration(cumulativeDuration),
          );
        }

        // Update currentPoint untuk iterasi berikutnya
        currentPoint = nextPoint;
      }

      // Tambahkan rute polyline dari startPoint ke titik terakhir
      final overallDirections = await DirectionsRepository().getDirections(
        origin: startPoint,
        destination: currentPoint,
        waypoints: points,
      );

      if (overallDirections != null) {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: overallDirections.polyline,
          width: 5,
          color: Colors.blue,
        ));
      }
    }

    notifyListeners();
  }

  void addMarker(BuildContext context, LatLng position, Rekap rekap,
      String distance, String duration) {
    _markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: 200,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF7DA0CA),
                borderRadius: BorderRadius.circular(4),
                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rekap.namaPembeli ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  // SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_car,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(distance,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(duration,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.add, color: Colors.white),
                                const SizedBox(width: 8),
                                Text("${rekap.jumlahKambing} ekor",
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.money, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(_formatCurrency(rekap.harga ?? 0),
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/goat.png',
                            width:
                                250, // sesuaikan lebar gambar sesuai kebutuhan
                            height:
                                130, // sesuaikan tinggi gambar sesuai kebutuhan
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            position,
          );
        },
      ),
    );
    notifyListeners();
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id')
        .format(value)
        .replaceAll(",00", "")
        .replaceAll('IDR', 'Rp. ');
  }

// Fungsi untuk mengonversi jarak ke dalam double
  double _parseDistance(String distance) {
    // Asumsikan format jarak adalah "XX.X km"
    return double.parse(distance.split(' ')[0]);
  }

// Fungsi untuk mengonversi durasi ke dalam double (dalam menit)
  double _parseDuration(String duration) {
    // Asumsikan format durasi adalah "X jam Y menit" atau "Y menit"
    final parts = duration.split(' ');
    double totalMinutes = 0.0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == 'hour') {
        totalMinutes += double.parse(parts[i - 1]) * 60;
      } else if (parts[i] == 'mins') {
        totalMinutes += double.parse(parts[i - 1]);
      }
    }

    return totalMinutes;
  }

// Fungsi untuk memformat jarak (dalam km)
  String _formatDistance(double distance) {
    return "${distance.toStringAsFixed(1)} km";
  }

// Fungsi untuk memformat durasi (dalam jam dan menit)
  String _formatDuration(double duration) {
    final hours = (duration / 60).floor();
    final minutes = (duration % 60).floor();

    if (hours > 0) {
      return "$hours jam $minutes menit";
    } else {
      return "$minutes menit";
    }
  }

  LatLngBounds getBounds(Set<Marker> markers) {
    final List<LatLng> positions =
        markers.map((marker) => marker.position).toList();
    final double southWestLatitude =
        positions.map((pos) => pos.latitude).reduce((a, b) => a < b ? a : b);
    final double southWestLongitude =
        positions.map((pos) => pos.longitude).reduce((a, b) => a < b ? a : b);
    final double northEastLatitude =
        positions.map((pos) => pos.latitude).reduce((a, b) => a > b ? a : b);
    final double northEastLongitude =
        positions.map((pos) => pos.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLatitude, southWestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );
  }

  CameraUpdate getCameraUpdate(Set<Marker> markers) {
    if (markers.length == 1) {
      final LatLng singlePosition = markers.first.position;
      return CameraUpdate.newLatLngZoom(singlePosition, 18);
    } else {
      final LatLngBounds bounds = getBounds(markers);
      return CameraUpdate.newLatLngBounds(bounds, 50);
    }
  }
}
