import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/screen/login/login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Unfocuser(
      child: Scaffold(
        resizeToAvoidBottomInset: false, 
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/login.jpg",
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/kejora_color.png",
                    height: 189,
                    width: 183,
                  ),
                  Gap(10),
                  Image.asset(
                    "assets/icons/logo white.png",
                    height: 189,
                    width: 183,
                  ),
                ],
              ),
            ),
            LoginWidget(),
          ],
        ),
      ),
    );
  }
}
