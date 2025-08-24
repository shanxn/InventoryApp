// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:inventory/auth/authverify.dart';
import 'package:inventory/auth/reg_log.dart';
import 'package:inventory/firebase.dart';
import 'package:inventory/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventory/firebase_options.dart';
import 'package:inventory/themes/darkmode.dart';
import 'package:inventory/themes/lightmode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Data data = Data();
  await data.getPermission();
  await data.init();
  await data.FcmToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
       // This trailing comma makes auto-formatting nicer for build methods.
       home: const authpage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
