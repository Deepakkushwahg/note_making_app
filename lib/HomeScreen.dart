// ignore_for_file: prefer_const_constructors, file_names, unnecessary_null_comparison
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_making_app/writtingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 35),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.black87,
                            elevation: 5,
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(500))),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return WrittingScreen();
                          }));
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        )),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Text(
                        "Welcome to Notes",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        "Have a nice day",
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firebase
                      .collection("Users")
                      .doc(auth.currentUser!.uid)
                      .collection('AllNotes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot data =
                                snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Card(
                                shadowColor: Colors.black87,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return WrittingScreen(
                                        title: data['title'],
                                        text: data['text'],
                                        docId: data['docId'],
                                      );
                                    }));
                                  },
                                  onLongPress: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            actionsAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            actionsPadding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            title: Text(
                                                "Are you sure you want to delete this?"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("No")),
                                              ElevatedButton(
                                                onPressed: () {
                                                  firebase
                                                      .collection("Users")
                                                      .doc(
                                                          auth.currentUser!.uid)
                                                      .collection("AllNotes")
                                                      .doc(data['docId'])
                                                      .delete();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Yes"),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(data['title']),
                                        Text(data['text']),
                                        SizedBox(height: 10),
                                        Text(
                                          (data['time'] as Timestamp) != null
                                              ? "${(data['time'] as Timestamp).toDate().day}/${(data['time'] as Timestamp).toDate().month}/${(data['time'] as Timestamp).toDate().year}"
                                              : "Loading....",
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.width / 1.5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Image(
                                fit: BoxFit.cover,
                                image: AssetImage('lib/images/notes-icon.png')),
                          ),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
