import 'package:flutter/material.dart';
import 'package:godus/models/user_model.dart';
import 'package:godus/utils/routes/routes_names.dart';
import 'package:godus/utils/utils.dart';
import 'package:godus/viewModel/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:godus/data/database/dbhelper.dart';

class AuthViewModel with ChangeNotifier {
  final _dbHelper = DatabaseHelper();

  bool _loginLoading = false;

  get loading => _loginLoading;

  void setLoginLoading(bool value) {
    _loginLoading = value;
    notifyListeners();
  }

  Future<void> localLogin(
      String username, String password, BuildContext context) async {
    setLoginLoading(true);
    final isValid = await _dbHelper.login(username, password);
    setLoginLoading(false);

    if (isValid) {
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      final token = await _dbHelper.getTokenByUsername(username);
      debugPrint(token); // Ambil token dari DatabaseHelper

      if (token != null && token.isNotEmpty) {
        userPreference.saveUser(UserModel(token: token));

        if (Navigator.canPop(context)) {
          Utils.showSuccessSnackBar(
            Overlay.of(context),
            "Login Berhasil",
          );

          Navigator.pushNamed(context, RouteNames.alamatScreen);
        } else {
          Utils.showSuccessSnackBar(
            Overlay.of(context),
            "Login Berhasil",
          );
        }
      } else {
        if (Navigator.canPop(context)) {
          Utils.showErrorSnackBar(
            Overlay.of(context),
            "Token Tidak Valid",
          );
        }
      }
    } else {
      if (Navigator.canPop(context)) {
        Utils.showErrorSnackBar(
          Overlay.of(context),
          "Data Tidak Valid",
        );
      }
    }
  }
}
