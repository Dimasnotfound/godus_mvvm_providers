import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/viewModel/tracking_view_model.dart';
import 'package:provider/provider.dart';
import 'package:godus/models/muatan_model.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  TextEditingController jumlahController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isDateSelected = false;

  @override
  void initState() {
    super.initState();
    // Panggil method untuk mengambil data latitude dan longitude dari database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrackingViewModel>(context, listen: false)
          .fetchGooglePlexLatLng();
      Provider.of<TrackingViewModel>(context, listen: false).fetchMuatan();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isDateSelected = true;
      });
    }
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCargoDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                    child: TextFormField(
                      controller: jumlahController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
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
                      int jumlah = int.parse(jumlahController.text);

                      // Panggil fungsi createMuatan dari ViewModel untuk membuat objek Muatan
                      Muatan muatan =
                          Provider.of<TrackingViewModel>(context, listen: false)
                              .createMuatan(jumlah);
                      await Provider.of<TrackingViewModel>(context,
                              listen: false)
                          .insertOrUpdateMuatan(muatan, context);
                      Navigator.of(context).pop();
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
              label: Text(
                isDateSelected
                    ? _getFormattedDate(selectedDate)
                    : 'Pilih Tanggal',
                style: const TextStyle(color: Color(0xFF401616)),
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
                  ), // Spacer
                  Consumer<TrackingViewModel>(
                    builder: (context, model, child) {
                      final muatan = model.muatan;
                      if (muatan != null) {
                        return Text(
                          muatan.jumlah
                              .toString(), // Ambil jumlah muatan dari database
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        );
                      } else {
                        return const Text(
                          'Muatan Kosong', // Tampilkan jika tidak ada data muatan
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
          return googlePlexLatLng != null
              ? GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: googlePlexLatLng,
                    zoom: 18,
                    // bearing: 192,
                    // tilt: 55,
                  ),
                  markers: <Marker>{
                    Marker(
                      markerId: const MarkerId("googlePlexMarker"),
                      position: googlePlexLatLng,
                      infoWindow: const InfoWindow(
                        title: "Googleplex",
                        snippet: "Google Headquarters",
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId("secondMarker"),
                      position: LatLng(googlePlexLatLng.latitude + 0.001,
                          googlePlexLatLng.longitude + 0.001),
                      infoWindow: const InfoWindow(
                        title: "Second Marker",
                        snippet: "Some description",
                      ),
                    ),
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
