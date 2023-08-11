import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterwavepayment/main.dart';
import 'package:flutterwavepayment/util_methods.dart';

import 'email_sender.dart';
import 'flutter_wave_page.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, this.uid});
  String? uid;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController feedbackController = TextEditingController();
  TextEditingController smsController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var feedbacks = FirebaseFirestore.instance.collection('userFeedback').get();
    feedbacks.then(
      (value) {
        log('Feedbacks: ${value.docs.first.data()}');
      },
    );
    log('UserId: ${widget.uid}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FlutterWavePage(title: 'Flutter Wave'),
                        ),
                      );
                    },
                    child: const Text('Flutter Wave'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailSender(),
                        ),
                      );
                    },
                    child: const Text('Email Sender'),
                  )
                ],
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: TextFormField(
                        controller: smsController,
                        validator: (value) {
                          if (value != null || value!.isEmpty) {
                            return 'Sms message should not be empty';
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Enter sms',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: TextFormField(
                        controller: phoneNumberController,
                        validator: (value) {
                          if (value != null || value!.isEmpty) {
                            return 'Enter valid phone number';
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Enter phone number',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    sendSMSMessage(
                        message: smsController.text,
                        recipients: [phoneNumberController.text.trim()]);
                    setState(() {
                      smsController.text = phoneNumberController.text = '';
                    });
                  },
                  child: Text('Send Sms')),
              const SizedBox(height: 50),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your feedback',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  var scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    await FirebaseFirestore.instance
                        .collection('userFeedback')
                        .add(
                      {
                        'feedBack': feedbackController.text,
                        'userId': widget.uid,
                        'timeStamp': DateTime.now().toUtc(),
                      },
                    );
                    scaffoldMessenger.showSnackBar(const SnackBar(
                      backgroundColor: Colors.green,
                      content:
                          Text('You have uploaded your feedback successfully'),
                    ));
                    setState(() {
                      feedbackController.text = '';
                    });
                  } on Exception catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Error: $err'),
                    ));
                  }
                },
                child: const Text('Send Feedback'),
              ),
              const SizedBox(height: 30),
              StreamBuilder<QuerySnapshot>(
                stream:
                    firebaseFirestore.collection('userFeedback').snapshots(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // height: 300,
                        child: ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((document) {
                            final feedback =
                                document.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(feedback['feedBack'] ?? ""),
                            );
                          }).toList(),
                        ));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ),
              const SizedBox(height: 50),
            ],
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ),
                );
              },
              child: const Text('Log out'),
            ),
          )
        ],
      ),
    );
  }
}
