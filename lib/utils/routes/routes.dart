import 'package:flutter/material.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/view/home_screen.dart';
import 'package:godus/view/login_screen.dart';
import 'package:godus/view/splash_screen.dart';
import 'package:godus/view/init_alamat_screen.dart';
import 'package:godus/view/rekap_screen.dart';
import 'package:godus/view/tracking_screen.dart';
import 'package:godus/view/akun_screen.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case (RouteNames.home):
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());
      case (RouteNames.login):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());
      case (RouteNames.splashScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());
      case (RouteNames.alamatScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const AlamatScreen());
      case (RouteNames.rekapScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const RekapScreen());
      case (RouteNames.trackingScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const TrackingScreen());
      case (RouteNames.akunScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const AkunScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("No route is configured"),
            ),
          ),
        );
    }
  }
}
