import 'package:flutter/material.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/viewModel/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashService.checkAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF215CA8),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -60,
            child: Image.asset(
              "assets/eclipse_screen_top.png", // Ganti dengan path gambar pertama
              width: screenWidth * 0.607625761, // Sesuaikan lebar gambar
              height: screenHeight * 0.2883333333, // Sesuaikan tinggi gambar
            ),
          ),
          // Gambar kedua (di kiri bawah)
          Positioned(
            bottom: 0,
            left: -60,
            child: Image.asset(
              "assets/eclipse_screen_bottom.png", // Ganti dengan path gambar kedua
              width: screenWidth * 0.607625761, // Sesuaikan lebar gambar
              height: screenHeight * 0.2883333333, // Sesuaikan tinggi gambar
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(8),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(const Color(0xFFFFFFFF)),
                ),
                onPressed: () {
                  // print(screenWidth);
                  // print(screenHeight);
                  Navigator.pushNamed(context, RouteNames.login);
                },
                child: const Text(
                  'GET STARTED',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF215CA8),
                  ),
                ),
              ),
            ),
          ),

          // Gambar ketiga (di tengah)
          Center(
            child: SizedBox(
              height: screenHeight * 0.2307692308,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/splash_screen_img.png"),
                  const SizedBox(
                      height: 20), // Tambahkan jarak antara gambar dan tombol
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
