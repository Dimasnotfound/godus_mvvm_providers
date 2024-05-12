import 'package:flutter/material.dart';
import 'package:godus/utils/routes/routes.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/viewModel/auth_viewmodel.dart';
import 'package:godus/viewModel/home_view_model.dart';
import 'package:godus/viewModel/user_view_model.dart';
import 'package:godus/viewModel/tracking_view_model.dart';
import 'package:godus/viewModel/init_alamat_view_model.dart';
import 'package:godus/viewModel/rekap_view_model.dart';
import 'package:godus/data/database/dbhelper.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await DatabaseHelper().database;
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => UserViewModel()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => AlamatViewModel()),
          ChangeNotifierProvider(create: (_) => TrackingViewModel()),
          ChangeNotifierProvider(create: (_) => RekapViewModel()),
        ],
        child: PopScope(
          canPop: false, // Set to false to prevent popping
          child: MaterialApp(
            title: 'Godus App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splashScreen,
            onGenerateRoute: Routes.generateRoutes,
          ),
          onPopInvoked: (bool isPop) async {
            if (isPop) {
              Navigator.pop(context);
            }
            return;
          },
        ));
  }
}
