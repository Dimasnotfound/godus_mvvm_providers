import 'package:flutter/material.dart';
// import 'package:godus/res/widgets/round_button.dart';
import 'package:godus/utils/utils.dart';
import 'package:godus/viewModel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:godus/utils/routes/routes_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ValueNotifier<bool> _obscureNotifier = ValueNotifier<bool>(false);
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final authViewModel = Provider.of<AuthViewModel>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF215CA8),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: -MediaQuery.of(context).size.height * 0.2,
            child: Center(
              child: Image.asset(
                'assets/loginbg.png', // Ubah dengan path gambar Anda
                width: screenWidth * 1.334, // Sesuaikan dengan kebutuhan
                height: screenHeight * 1.1547, // Sesuaikan dengan kebutuhan
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/splash_screen_img.png', // Ubah dengan path gambar Anda
                width: screenWidth * 0.486, // Sesuaikan dengan kebutuhan
                height:
                    screenHeight * 0.2307692308, // Sesuaikan dengan kebutuhan
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.138408778,
            left: 0,
            child: Center(
              child: Image.asset(
                'assets/LOGIN.png', // Ubah dengan path gambar Anda
                width: screenWidth * 0.486, // Sesuaikan dengan kebutuhan
                height: screenHeight *
                    0.2307692308, // Sesuaikan dengan kebutuhan, // Sesuaikan dengan kebutuhan
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/eclipse_login_bottom.png', // Ubah dengan path gambar Anda
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height:
                          screenHeight * 0.173196688), // Beri jarak dari atas
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 5.0), // Menambahkan margin kiri
                          child: Text(
                            'Username', // Teks di atas inputan
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Color(0xFF4D4D4D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (_) {
                            Utils.changeNodeFocus(context,
                                current: _usernameFocus, next: _passwordFocus);
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF4D4D4D),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFA7A7A7),
                                width: 1.5, // Warna border saat tidak aktif
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFA7A7A7),
                                width: 2.5, // Warna border saat aktif
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 5.0), // Menambahkan margin kiri
                          child: Text(
                            'Password', // Teks di atas inputan
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Color(0xFF4D4D4D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscureNotifier,
                          builder: (context, value, child) {
                            return TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: !_obscureNotifier.value,
                              obscuringCharacter: "*",
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF4D4D4D),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNotifier.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF4D4D4D),
                                  ),
                                  onPressed: () {
                                    _obscureNotifier.value =
                                        !_obscureNotifier.value;
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFA7A7A7),
                                    width: 1.5, // Warna border saat tidak aktif
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFA7A7A7),
                                    width: 2.5, // Warna border saat aktif
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0), // Tambahkan padding di sini
                      child: ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text.isEmpty &&
                              _passwordController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Data Tidak Valid",
                            );
                          } else if (_passwordController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Password Kosong",
                            );
                          } else if (_usernameController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Username Kosong",
                            );
                          } else {
                            authViewModel.localLogin(
                              _usernameController.text,
                              _passwordController.text,
                              context,
                            );
                            debugPrint("hit local login");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF215CA8),
                          elevation: 8, // Warna latar belakang putih
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: screenWidth *
                                  0.218570357), // Tambahkan padding di sini
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 22, // Ukuran teks
                              fontFamily: 'Poppins', // Menggunakan font Poppins
                              fontWeight:
                                  FontWeight.w600, // Berat font menjadi bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: height * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 0.0),
        child: MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.splashScreen);
          },
          color: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          splashColor:
              Colors.transparent, // Menghilangkan efek splash saat ditekan
          highlightColor: Colors
              .transparent, // Menghilangkan efek highlight saat ditekan // Warna saat tombol diklik
          child: const Row(
            children: [
              Icon(Icons.chevron_left, color: Color(0xFFFFFFFF)), // Warna ikon
              SizedBox(width: 5), // Jarak antara ikon dan teks
              Text(
                'Back',
                style: TextStyle(
                  fontFamily: 'Poppins', // Font Poppins
                  fontWeight: FontWeight.bold, // Tebal
                  color: Color(0xFFFFFFFF), // Warna teks
                  fontSize: 18, // Ukuran teks
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
