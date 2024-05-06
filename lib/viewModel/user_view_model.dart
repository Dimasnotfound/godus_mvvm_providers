import 'package:flutter/cupertino.dart';
import 'package:godus/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {
  // !SAVE THE USER and set the state!
  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("token", user.token.toString());
    notifyListeners(); // so that theuser is saved!

    return true;
  }

// REMOVE THE USER and set the state
  Future<bool> removeUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    // Mengecek apakah token ada sebelum dihapus
    final bool tokenExistsBefore = sp.containsKey("token");
    // Menghapus token
    await sp.remove("token");
    // Mengecek apakah token ada setelah dihapus
    final bool tokenExistsAfter = sp.containsKey("token");
    // Memeriksa apakah token berhasil dihapus
    final bool tokenRemoved = !tokenExistsBefore && !tokenExistsAfter;
    if (tokenRemoved) {
      notifyListeners(); // so that the user is removed!
    }
    return tokenRemoved;
  }

  // ! get The User

  Future<UserModel?> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? token = sp.getString("token");
    return UserModel(token: token.toString());
  }
}
