// ignore_for_file: prefer_const_constructors, file_names, use_build_context_synchronously, avoid_print, must_be_immutable, no_logic_in_create_state, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_making_app/AuthenticationScreen.dart';
import 'package:uuid/uuid.dart';

class WrittingScreen extends StatefulWidget {
  String? title, text, docId;
  WrittingScreen({Key? key, this.title, this.text, this.docId})
      : super(key: key);

  @override
  State<WrittingScreen> createState() =>
      _WrittingScreenState(title, text, docId);
}

class _WrittingScreenState extends State<WrittingScreen> {
  String? title, text, docId;
  _WrittingScreenState(this.title, this.text, this.docId);
  TextEditingController titleController = TextEditingController();
  TextEditingController textController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    if (docId != null) {
      setState(() {
        titleController.text = title.toString();
        textController.text = text.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.black87,
                            elevation: 5,
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(500))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        )),
                  ),
                  // ignore: prefer_const_literals_to_create_immutables
                  Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black87,
                                elevation: 5,
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(500))),
                            onPressed: () {
                              if (docId != null) {
                                firebase
                                    .collection("Users")
                                    .doc(auth.currentUser!.uid)
                                    .collection("AllNotes")
                                    .doc(docId)
                                    .delete();
                              }
                              textController.clear();
                              titleController.clear();
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 20,
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black87,
                                elevation: 5,
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(500))),
                            onPressed: () {
                              saveNotes();
                            },
                            child: Icon(
                              Icons.save,
                              color: Colors.black,
                              size: 20,
                            )),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: titleController,
                minLines: 1,
                maxLines: 3,
                cursorHeight: 30,
                style: TextStyle(fontSize: 28),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    border: InputBorder.none),
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  minLines: 1,
                  maxLines: MediaQuery.of(context).size.hashCode,
                  cursorHeight: 20,
                  style: TextStyle(fontSize: 18),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: "Enter Your Text Here",
                      hintStyle: TextStyle(color: Colors.black, fontSize: 18),
                      border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveNotes() async {
    try {
      showSnackBar(context, "saving........");
      if (docId != null) {
        await firebase
            .collection("Users")
            .doc(auth.currentUser!.uid)
            .collection("AllNotes")
            .doc(docId)
            .update({
          "title":
              (titleController.text.isEmpty) ? "Title" : titleController.text,
          "text": (textController.text.isEmpty) ? "" : textController.text,
          "time": FieldValue.serverTimestamp(),
        });
      } else {
        String _docId = Uuid().v1();
        await firebase
            .collection("Users")
            .doc(auth.currentUser!.uid)
            .collection("AllNotes")
            .doc(_docId)
            .set({
          "title":
              (titleController.text.isEmpty) ? "Title" : titleController.text,
          "text": (textController.text.isEmpty) ? "" : textController.text,
          "time": FieldValue.serverTimestamp(),
          "docId": _docId
        });
      }
      showSnackBar(context, "save");
      print("save");
      Navigator.of(context).pop();
    } catch (e) {
      showSnackBar(context, "failed please try again");
      print("failed due to - $e");
    }
  }
}
