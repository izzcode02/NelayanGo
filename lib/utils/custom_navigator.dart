import 'package:flutter/material.dart';

class cNavigate {
  static void goToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/admin/dashboard');
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }
  static void goToHomeScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/users/home');
  }
  static void goToSummary(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/users/summary');
  }
  static void goToConfigure(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/users/configure');
  }
}
