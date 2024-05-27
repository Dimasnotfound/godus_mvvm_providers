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
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:quickalert/quickalert.dart';

class TrackingViewModel with ChangeNotifier {
  TextEditingController jumlahController = TextEditingController();
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

  Future<void> insertOrUpdateMuatan(
      Muatan muatan, BuildContext context, bool type) async {
    final db = DatabaseHelper();
    await db.insertOrUpdateMuatan(muatan);
    if (type) {
      Utils.showSuccessSnackBar(
        Overlay.of(context),
        "Data Berhasil Diubah",
      );
    }
    await fetchMuatan();
  }

  Future<void> fetchMuatan() async {
    final db = DatabaseHelper();
    _muatan = await db.getMuatan();
    notifyListeners();

    // Set jumlahController dengan nilai dari _muatan setelah fetchMuatan()
    if (_muatan != null) {
      jumlahController.text = _muatan!.jumlah.toString();
    }
  }

  Muatan? get muatan => _muatan;

  Future<void> fetchGooglePlexLatLng() async {
    _markers.clear();
    final alamatPenjualList = await DatabaseHelper().getAlamatPenjualList();
    if (alamatPenjualList.isNotEmpty) {
      final AlamatPenjual alamatPenjual = alamatPenjualList.first;
      final latitude = alamatPenjual.latitude;
      final longitude = alamatPenjual.longitude;

      // print(alamatPenjual.latitude);
      // print(alamatPenjual.longitude);

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
    customInfoWindowController.hideInfoWindow!();
    clearMarkers();
    _polylines.clear();
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

    points = Haversine.sortPointsByDistance(_googlePlexLatLng!, points);

    if (points.isNotEmpty) {
      LatLng startPoint = _googlePlexLatLng!;
      LatLng currentPoint = startPoint;

      double cumulativeDistance = 0.0;
      double cumulativeDuration = 0.0;

      for (int i = 0; i < points.length; i++) {
        LatLng nextPoint = points[i];

        final directions = await DirectionsRepository().getDirections(
          origin: currentPoint,
          destination: nextPoint,
        );

        if (directions != null) {
          cumulativeDistance += _parseDistance(directions.totalDistance);
          cumulativeDuration += _parseDuration(directions.totalDuration);

          // Assigning an initial value to rekap
          Rekap rekap = rekapList![i];

          // print('==========================');
          // print(rekap);

          // Cari data rekap yang sesuai dengan latlng yang telah diurutkan
          for (Rekap r in rekapList) {
            final AlamatPembeli? alamatPembeli =
                await DatabaseHelper().getAlamatPembeliById(r.idAlamatPembeli!);
            if (alamatPembeli != null) {
              final LatLng position = LatLng(
                  alamatPembeli.latitude ?? 0, alamatPembeli.longitude ?? 0);
              if (position == nextPoint) {
                rekap = r;
                break;
              }
            }
          }

          addMarker(
            context,
            nextPoint,
            rekap,
            _formatDistance(cumulativeDistance),
            _formatDuration(cumulativeDuration),
            date,
          );
        }

        currentPoint = nextPoint;
      }

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
    checkMuatanAndShowAlert(context);
  }

  void addMarker(BuildContext context, LatLng position, Rekap rekap,
      String distance, String duration, DateTime date) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _markers.add(
      Marker(
        markerId: MarkerId('${position}jumlah=${rekap.jumlahKambing}'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: 200,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF7DA0CA),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rekap.namaPembeli ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: rekap.idStatusPengantaran == 1
                            ? () async {
                                int jumlahControllerValue =
                                    int.tryParse(jumlahController.text) ?? 0;
                                int rekapJumlahKambing =
                                    rekap.jumlahKambing ?? 0;

                                if (jumlahControllerValue <
                                    rekapJumlahKambing) {
                                  checkMuatanAndShowAlert(context);
                                  return;
                                }

                                PanaraConfirmDialog.showAnimatedGrow(
                                  context,
                                  title: "Konfirmasi",
                                  message:
                                      "Apakah Anda Ingin Mengubah Status Pengantaran?",
                                  confirmButtonText: "Iya",
                                  cancelButtonText: "Tidak",
                                  onTapCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onTapConfirm: () async {
                                    await ubahStatusPengantaran(
                                        context, rekap.id!);

                                    jumlahControllerValue -= rekapJumlahKambing;

                                    Muatan muatan =
                                        createMuatan(jumlahControllerValue);
                                    await insertOrUpdateMuatan(
                                        muatan, context, false);
                                    Utils.showSuccessSnackBar(
                                      Overlay.of(context),
                                      "Pengiriman Selesai",
                                    );

                                    jumlahController.text =
                                        jumlahControllerValue.toString();
                                    Navigator.pop(context);
                                    customInfoWindowController
                                        .hideInfoWindow!();
                                    await fetchRekapByDate(context, date);
                                  },
                                  panaraDialogType: PanaraDialogType.normal,
                                );
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (states) {
                              if (rekap.idStatusPengantaran == 1) {
                                return Colors.red;
                              } else {
                                return Colors.green;
                              }
                            },
                          ),
                        ),
                        child: Text(
                          rekap.idStatusPengantaran == 1 ? 'On Going' : 'Done',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            width: screenWidth * 0.3333,
                            height: screenHeight * 0.1184,
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

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id')
        .format(value)
        .replaceAll(",00", "")
        .replaceAll('IDR', 'Rp. ');
  }

  double _parseDistance(String distance) {
    return double.parse(distance.split(' ')[0]);
  }

  double _parseDuration(String duration) {
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

  String _formatDistance(double distance) {
    return "${distance.toStringAsFixed(1)} km";
  }

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

  void checkMuatanAndShowAlert(BuildContext context) {
    if (_muatan != null && _markers.isNotEmpty && _markers.length > 1) {
      // Ambil marker kedua (index ke-1)
      Marker marker = _markers.elementAt(1);

      // Informasi yang diperlukan dari marker kedua
      String markerId = marker.markerId.toString();

      // Cari posisi index awal 'jumlah='
      int startIndex = markerId.indexOf('jumlah=') + 'jumlah='.length;

      // Cari posisi index akhir ')'
      int endIndex = markerId.indexOf(')', startIndex);

      // Ambil substring mulai dari index awal 'jumlah=' hingga sebelum karakter ')'
      String jumlahKambingPembeliString =
          markerId.substring(startIndex, endIndex);

      // Parse string menjadi integer
      int jumlahKambingPembeli = int.tryParse(jumlahKambingPembeliString) ?? 0;
      int jumlahMuatan = int.tryParse(jumlahController.text) ?? 0;

      if (jumlahMuatan < jumlahKambingPembeli) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Peringatan',
          text: 'Muatan Kurang!!',
        );
      }
    }
  }
}
