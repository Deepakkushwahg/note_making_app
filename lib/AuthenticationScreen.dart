// ignore_for_file: prefer_const_constructors, file_names, implementation_imports, unnecessary_import, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_making_app/HomeScreen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  TextEditingController numberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  String otp = "", verificationId = "";
  bool isLoading = false;
  User? user;
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image(
                  fit: BoxFit.cover,
                  image: AssetImage('lib/images/design.png')),
            ),
            Positioned.fill(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                  Text(
                    "Welcome to Notes",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        // ignore: prefer_const_literals_to_create_immutables
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0),
                          BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: TextField(
                        controller: numberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            prefixText: "+91 ",
                            prefixStyle:
                                TextStyle(color: Colors.black, fontSize: 16),
                            labelText: "Enter the mobile number",
                            labelStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextField(
                        style: TextStyle(fontSize: 20),
                        controller: otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter OTP",
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        VerifyPhone(setData);
                      },
                      child: Text(
                        "Send OTP",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.black,
                            elevation: 5,
                            primary: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1000))),
                        onPressed: () {
                          if (otpController.text.length == 6 &&
                              numberController.text.length == 10) {
                            setState(() {
                              otp = otpController.text;
                              isLoading = true;
                            });
                            signInWithPhoneNumber();
                          } else if (otpController.text.length != 6) {
                            showSnackBar(context, "Please enter correct otp");
                          } else {
                            showSnackBar(context, "Please enter phone number");
                          }
                        },
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40,
                        )),
                  ),
                ],
              ),
            )),
            Positioned(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Center())
          ],
        ),
      ),
    );
  }

  void setData(vID) {
    setState(() {
      verificationId = vID;
    });
  }

  Future<void> signInWithPhoneNumber() async {
    try {
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      UserCredential userCredential =
          await auth.signInWithCredential(authCredential);
      if (userCredential.user != null) {
        storage.write(key: "uid", value: userCredential.user!.uid);
      }
      setState(() {
        user = userCredential.user;
        isLoading = false;
      });
      showSnackBar(context, "Register successfuly");
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "signin failed due to ${e.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> VerifyPhone(Function setData) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: '+91 ${numberController.text}}',
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          showSnackBar(
              context, "phone verified : Token ${authCredential.token}");
        },
        verificationFailed: (FirebaseAuthException e) {
          showSnackBar(
              context, "verification failed due to ${e.message.toString()}");
        },
        codeSent: (String vID, [int? resentToken]) {
          setData(vID);
          showSnackBar(context, "code sent");
        },
        codeAutoRetrievalTimeout: (String vID) {
          setState(() {
            verificationId = vID;
            showSnackBar(context, "Time out");
          });
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      showSnackBar(
          context, "verifyphone exception catched due to ${e.toString()}");
    }
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: 800),
  ));
}
