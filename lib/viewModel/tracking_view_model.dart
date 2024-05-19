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

class TrackingViewModel with ChangeNotifier {
  LatLng? _googlePlexLatLng;
  Muatan? _muatan;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  DateTime? _selectedDate;

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

      _markers.add(
        Marker(
          markerId: const MarkerId("googlePlexMarker"),
          position: _googlePlexLatLng!,
          infoWindow: const InfoWindow(
            title: "Googleplex",
            snippet: "Google Headquarters",
          ),
        ),
      );

      notifyListeners();
    }
  }

  LatLng? get googlePlexLatLng => _googlePlexLatLng;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  DateTime? get selectedDate => _selectedDate;

  void clearMarkers() {
    _markers.clear();
    if (_googlePlexLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("googlePlexMarker"),
          position: _googlePlexLatLng!,
          infoWindow: const InfoWindow(
            title: "Googleplex",
            snippet: "Google Headquarters",
          ),
        ),
      );
    }
    notifyListeners();
  }

  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }

  Future<void> fetchRekapByDate(DateTime date) async {
    _selectedDate = date;
    clearMarkers();
    clearPolylines();

    final List<Rekap>? rekapList = await DatabaseHelper().getRekapByDate(date);
    if (rekapList != null && rekapList.isNotEmpty) {
      List<LatLng> points = [];
      for (Rekap rekap in rekapList) {
        final int? idAlamatPembeli = rekap.idAlamatPembeli;
        if (idAlamatPembeli != null) {
          final AlamatPembeli? alamatPembeli =
              await DatabaseHelper().getAlamatPembeliById(idAlamatPembeli);
          if (alamatPembeli != null) {
            final LatLng position = LatLng(
                alamatPembeli.latitude ?? 0, alamatPembeli.longitude ?? 0);
            points.add(position);
            addMarker(position);
          }
        }
      }

      if (_googlePlexLatLng != null) {
        points = Haversine.sortPointsByDistance(_googlePlexLatLng!, points);

        for (int i = 0; i < points.length - 1; i++) {
          await _addPolyline(points[i], points[i + 1]);
        }
      }
    }
  }

  void addMarker(LatLng position) {
    _markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: const InfoWindow(
          title: "Alamat Pembeli",
          snippet: "Deskripsi alamat pembeli",
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> _addPolyline(LatLng start, LatLng end) async {
    final directions = await DirectionsRepository().getDirections(start, end);
    
    if (directions != null) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('${start.toString()}-${end.toString()}'),
          color: Colors.blue,
          width: 5,
          points: directions.polyline,
        ),
      );
      notifyListeners();
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
