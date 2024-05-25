// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/viewModel/tracking_view_model.dart';
import 'package:provider/provider.dart';
import 'package:godus/models/muatan_model.dart';
import 'package:intl/intl.dart';
import 'package:custom_info_window/custom_info_window.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrackingViewModel>(context, listen: false)
          .fetchGooglePlexLatLng();
      Provider.of<TrackingViewModel>(context, listen: false).fetchMuatan();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = Provider.of<TrackingViewModel>(context, listen: false);
    final selectedDate = viewModel.selectedDate;
    if (selectedDate != null) {
      Future.microtask(() async {
        await viewModel.fetchRekapByDate(context, selectedDate);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          context.read<TrackingViewModel>().selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      await context.read<TrackingViewModel>().fetchRekapByDate(context, picked);
      _updateCamera(context.read<TrackingViewModel>().markers);
    }
  }

  void _updateCamera(Set<Marker> markers) {
    if (_controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller!.animateCamera(
          context.read<TrackingViewModel>().getCameraUpdate(markers),
        );
      });
    }
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return '';
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  void _showCargoDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<TrackingViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Tambah Muatan",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: const Color(0xFF215CA8),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.114286,
                    height: screenHeight * 0.075,
                    child: Image.asset(
                      'assets/baphomet1.png',
                      width: screenWidth * 0.114286,
                      height: screenHeight * 0.075,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth *
                            0.5, // Sesuaikan lebar input sesuai kebutuhan
                        height: screenHeight * 0.075,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: viewModel.jumlahController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                labelStyle: const TextStyle(
                                    color: Colors.black, fontFamily: 'Poppins'),

                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        12.0), // Tambahkan padding horizontal
                              ),
                              style: const TextStyle(
                                  color: Colors.black, fontFamily: 'Poppins'),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  int currentValue = int.tryParse(
                                          viewModel.jumlahController.text) ??
                                      0;
                                  int updatedValue = currentValue + 1;
                                  viewModel.jumlahController.text =
                                      updatedValue.toString();
                                },
                                icon: Icon(Icons.add),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: IconButton(
                                onPressed: () {
                                  int currentValue = int.tryParse(
                                          viewModel.jumlahController.text) ??
                                      0;
                                  int updatedValue = currentValue - 1;
                                  if (updatedValue >= 0) {
                                    viewModel.jumlahController.text =
                                        updatedValue.toString();
                                  }
                                },
                                icon: Icon(Icons.remove),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 4,
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      int jumlah = int.parse(viewModel.jumlahController.text);

                      Muatan muatan =
                          Provider.of<TrackingViewModel>(context, listen: false)
                              .createMuatan(jumlah);
                      await Provider.of<TrackingViewModel>(context,
                              listen: false)
                          .insertOrUpdateMuatan(muatan, context,true);
                      Navigator.of(context).pop();

                      viewModel.checkMuatanAndShowAlert(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 4,
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _selectDate(context),
              elevation: 6,
              label: Consumer<TrackingViewModel>(
                builder: (context, model, child) {
                  final selectedDate = model.selectedDate;
                  return Text(
                    selectedDate != null
                        ? _getFormattedDate(selectedDate)
                        : 'Pilih Tanggal',
                    style: const TextStyle(color: Color(0xFF401616)),
                  );
                },
              ),
              icon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF401616),
              ),
              backgroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                side:
                    const BorderSide(color: Color(0xFFCCCCCC)), // warna border
                borderRadius: BorderRadius.circular(20), // radius border
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.extended(
              onPressed: () => _showCargoDialog(context),
              elevation: 10,
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Muatan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Consumer<TrackingViewModel>(
                    builder: (context, model, child) {
                      final jumlah = model.jumlahController.text;
                      if (jumlah.isNotEmpty) {
                        return Text(
                          jumlah,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        );
                      } else {
                        return const Text(
                          'Muatan "0"',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              icon: Image.asset(
                'assets/baphomet1.png',
                width: screenWidth * 0.1142857142857143,
                height: screenHeight * 0.0553636363636364,
              ),
              backgroundColor: const Color(0xFF215CA8),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Consumer<TrackingViewModel>(
        builder: (context, model, child) {
          final googlePlexLatLng = model.googlePlexLatLng;
          final markers = model.markers;
          final polylines = model.polylines;

          if (_controller != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller!.animateCamera(
                model.getCameraUpdate(markers),
              );
            });
          }

          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: googlePlexLatLng ?? const LatLng(0, 0),
                  zoom: 18,
                ),
                markers: markers,
                polylines: polylines,
                onMapCreated: (controller) {
                  _controller = controller;
                  _controller!.animateCamera(
                    model.getCameraUpdate(markers),
                  );
                  model.customInfoWindowController.googleMapController =
                      controller;
                },
                onTap: (position) {
                  model.customInfoWindowController.hideInfoWindow!();
                },
                onCameraMove: (position) {
                  model.customInfoWindowController.onCameraMove!();
                },
              ),
              CustomInfoWindow(
                controller: model.customInfoWindowController,
                height: 160, //ubah bagian ini
                width: 300, //ubah bagian ini
                offset: 50, //ubah bagian ini
              ),
            ],
          );
        },
      ),
    );
  }
}
