import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> isAlreadyLogin(BuildContext context) async {
    User? user = _auth.currentUser;
    try {
      if (user != null) {
        if (user.email == 'muziumnelayan@yahoo.com') {
          Timer(
              const Duration(seconds: 3),
              () =>
                  cNavigate.goToDashboard(context));
        } else {
          Timer(const Duration(seconds: 3),
              () => cNavigate.goToHomeScreen(context));
        }
      } else {
        Timer(const Duration(seconds: 3),
            () => cNavigate.goToLogin(context));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    isAlreadyLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/login.jpg",
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green,
                  width: 4,
                ),
              ),
              child: Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
