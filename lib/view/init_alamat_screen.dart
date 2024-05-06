import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:godus/viewModel/init_alamat_view_model.dart';
import 'package:provider/provider.dart';

class AlamatScreen extends StatefulWidget {
  const AlamatScreen({super.key});

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  AlamatViewModel am = AlamatViewModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final alamatViewModel = Provider.of<AlamatViewModel>(context);
    alamatViewModel.fetchDataAndFillTextControllers();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF215CA8),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/splash_screen_img.png',
                width: screenWidth * 0.486,
                height: screenHeight * 0.2307692308,
              ),
            ),
          ),
          Positioned(
            top: 20,
            bottom: 0,
            // left: 0,
            right: -55,
            child: Center(
              child: Image.asset(
                'assets/initbg.png',
                width: screenWidth * 1.2142857143,
                height: screenHeight * 0.8307692308,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 40,
            child: Center(
              child: Image.asset(
                'assets/MASUKKAN_ALAMAT.png', // Ubah dengan path gambar Anda
                width: screenWidth * 0.486, // Sesuaikan dengan kebutuhan
                height:
                    screenHeight * 0.2307692308, // Sesuaikan dengan kebutuhan
              ),
            ),
          ),
          Positioned(
            top: screenWidth * 0.487,
            left: 20,
            right: 20,
            child: Padding(
              padding: const EdgeInsets.all(25.0), // Tambahkan padding di sini
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 20), // Tambahkan SizedBox di sini untuk jarak
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: buildTextField(
                            "Dusun", alamatViewModel.dusunController),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            buildTextField("RT", alamatViewModel.rtController),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            buildTextField("RW", alamatViewModel.rwController),
                      ),
                    ],
                  ),
                  buildTextField("Jalan", alamatViewModel.jalanController),
                  buildTextField("Desa", alamatViewModel.desaController),
                  buildTextField(
                      "Kecamatan", alamatViewModel.kecamatanController),
                  buildTextField(
                      "Kabupaten", alamatViewModel.kabupatenController),
                  const SizedBox(height: 10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0), // Tambahkan padding di sini
                      child: ElevatedButton(
                        onPressed: () {
                          alamatViewModel.saveOrUpdateAlamat(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF215CA8),
                          elevation: 8, // Warna latar belakang putih
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 60.0), // Tambahkan padding di sini
                          child: Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 18, // Ukuran teks
                              fontFamily: 'Poppins', // Menggunakan font Poppins
                              fontWeight:
                                  FontWeight.w600, // Berat font menjadi bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Color(0xFF4D4D4D),
              fontFamily: 'Poppins'), // Menambahkan font Poppins
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(18), // Mengatur border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(18), // Mengatur border radius
          ),
        ),
        style: GoogleFonts.poppins(
            color: const Color(0xFF4D4D4D)), // Menggunakan font Poppins
      ),
    );
  }
}
