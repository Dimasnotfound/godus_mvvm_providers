// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:godus/viewModel/akun_view_model.dart';
import 'package:provider/provider.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/utils/utils.dart';
import 'package:godus/viewModel/user_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AkunViewModel>(context, listen: false).getDataAkun();
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<UserViewModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(33, 92, 168, 1),
      body: Stack(
        children: [
          Positioned.fill(
            top: 100,
            child: Image.asset(
              'assets/bgprofil.png', // Ganti dengan path gambar background Anda
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            top: 50,
            left: 25,
            child: Text(
              'Akun',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: (MediaQuery.of(context).size.width - 285) / 2,
            child: Consumer<AkunViewModel>(
              builder: (context, model, child) {
                final username = model.user?.username ?? 'Guest';
                final alamat = model.alamat;
                final alamatSubtitle =
                    '${alamat?.jalan ?? ''}, ${alamat?.kecamatan ?? ''}, ${alamat?.kabupaten ?? ''}';
                return Column(
                  children: [
                    buildInfoContainer(
                      imageAsset: 'assets/username.png',
                      title: 'Username',
                      subtitle: username,
                      onEditPressed: () {
                        // Implement your edit functionality here
                      },
                    ),
                    const SizedBox(height: 20), // Add space between containers
                    buildInfoContainer(
                      imageAsset: 'assets/alamat.png',
                      title: 'Alamat',
                      subtitle: alamatSubtitle,
                      showEditButton: true,
                      onEditPressed: () {
                        _showAlamatWidget(context);
                        // _showMapWidget(context);
                      },
                    ),
                    const SizedBox(
                        height: 40), // Add space before logout button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            preferences.removeUser().then((value) {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, RouteNames.login);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            elevation: 8,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20,
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 22, // Ukuran teks
                                fontFamily:
                                    'Poppins', // Menggunakan font Poppins
                                fontWeight:
                                    FontWeight.w600, // Berat font menjadi bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAlamatWidget(BuildContext context) {
    final viewModel = Provider.of<AkunViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // lebar dialog
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child:
                            buildTextField(viewModel.dusunController, "Dusun"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rtController, "RT"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rwController, "RW"),
                      ),
                    ],
                  ),
                  buildTextField(viewModel.jalanController, "Jalan"),
                  buildTextField(viewModel.desaController, "Desa"),
                  buildTextField(viewModel.kecamatanController, "Kecamatan"),
                  buildTextField(viewModel.kabupatenController, "Kabupaten"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          viewModel.rasetAlamatControllers();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'BATAL',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Periksa apakah ada yang kosong
                          if (viewModel.dusunController.text.isEmpty ||
                              viewModel.rtController.text.isEmpty ||
                              viewModel.rwController.text.isEmpty ||
                              viewModel.jalanController.text.isEmpty ||
                              viewModel.desaController.text.isEmpty ||
                              viewModel.kecamatanController.text.isEmpty ||
                              viewModel.kabupatenController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Data Tidak Boleh Kosong",
                            );
                          } else {
                            await viewModel.getLatLng(context);
                            _showMapWidget(
                                context); // Tutup dialog setelah mendapatkan lat-long
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF215CA8),
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMapWidget(BuildContext context) {
    final viewModel = Provider.of<AkunViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Set Lokasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: screenHeight * 0.3947, //ubah bagian sini
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                zoom: 17,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("alamat"),
                  position:
                      LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                  draggable: true,
                  onDragEnd: (LatLng newPosition) {
                    viewModel.latitude = newPosition.latitude;
                    viewModel.longitude = newPosition.longitude;
                  },
                ),
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.updateAlamatPenjual(context);
                Navigator.pop(context);
                Utils.showSuccessSnackBar(
                  Overlay.of(context),
                  "Data Berhasil Diubah!",
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF215CA8),
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4D4D4D),
            fontFamily: 'Poppins',
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget buildInfoContainer({
    required String imageAsset,
    required String title,
    required String subtitle,
    bool showEditButton =
        false, // Tambahkan properti untuk menampilkan tombol edit
    required VoidCallback? onEditPressed, // VoidCallback bersifat opsional
  }) {
    return Container(
      width: 285,
      height: 119,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(33, 92, 168, 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Image.asset(
              imageAsset,
              width: 44,
              height: 46,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35), // Penambahan jarak ke bawah
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2), // Penambahan jarak ke bawah
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis, // Menambahkan overflow
                ),
              ],
            ),
          ),
          if (showEditButton) // Tampilkan tombol edit jika properti showEditButton true
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEditPressed,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
