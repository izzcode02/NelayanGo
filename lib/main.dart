
import 'package:firebase_core/firebase_core.dart'; //new
import 'package:flutter/material.dart'; //new
import 'package:fullscreen/fullscreen.dart';
import 'package:nelayanpos/screen/admin/home_screen.dart';
import 'package:nelayanpos/screen/login/login_screen.dart';
import 'package:nelayanpos/screen/splashscreen/splash_screen.dart';
import 'package:nelayanpos/screen/users/configurations/configure.dart';
import 'package:nelayanpos/screen/users/home_screen.dart';
import 'package:nelayanpos/screen/users/summarylist.dart';
import 'package:nelayanpos/services/auth.dart';

AuthService auth = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NelayanGO POS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        //login
        '/login': (context) => LoginScreen(),
    
        //user
        '/users/home': (context) => UserScreen(),
        '/users/summary': (context) => SummaryScreen(),
        '/users/configure' : (context) => Configure(),
    
        //admin
        '/admin/dashboard': (context) => AdminScreen(),
      },
    );
  }
}
