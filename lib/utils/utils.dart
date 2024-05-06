import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class Utils {
  static void changeNodeFocus(BuildContext context,
      {required FocusNode current, required FocusNode next}) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  static void toastMessage(String message) {
    // Implementasi toast message menggunakan library lain
  }

  static void showSuccessSnackBar(OverlayState overlay, String message) {
    showTopSnackBar(
      overlay,
      CustomSnackBar.success(
        message: message,
      ),
    );
  }

  static void showErrorSnackBar(OverlayState overlay, String message) {
    showTopSnackBar(
      overlay,
      CustomSnackBar.error(
        message: message,
      ),
    );
  }

  static double averageRatings(List<int> ratings) {
    double avg = 0;
    for (int i = 0; i < ratings.length; i++) {
      avg += ratings[i];
    }
    avg /= ratings.length;

    return avg;
  }
}
