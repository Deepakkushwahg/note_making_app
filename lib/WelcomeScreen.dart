// ignore_for_file: prefer_const_constructors, unnecessary_import, implementation_imports, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_making_app/AuthenticationScreen.dart';

import 'HomeScreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final storage = FlutterSecureStorage();
  Widget currentPage = AuthenticationScreen();
  @override
  void initState() {
    super.initState;
    setData();
    startTimer(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:
          Image(fit: BoxFit.cover, image: AssetImage('lib/images/splash.png')),
    ));
  }

  void startTimer(int start) {
    const onsec = Duration(seconds: 1);
    Timer.periodic(onsec, (timer) {
      if (start == 0) {
        timer.cancel();
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return currentPage;
        }));
      } else {
        start--;
      }
    });
  }

  void setData() async {
    String? uid = await storage.read(key: "uid");
    setState(() {
      (uid == null)
          ? currentPage = AuthenticationScreen()
          : currentPage = HomeScreen();
    });
  }
}
