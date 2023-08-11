import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterwavepayment/util_methods.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_flutter/icons_flutter.dart';

import 'firebase_options.dart';
import 'home_page.dart';

bool shouldUseFirebaseEmulator = false;

late final FirebaseApp app;
late final FirebaseAuth auth;
GoogleSignIn googleSignIn = GoogleSignIn();
late UserCredential userCredential;
late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
final FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuth.instanceFor(app: app);

  FirebaseMessaging.onBackgroundMessage(backgroundMessagingHandler);
  String? registrationToken = await FirebaseMessaging.instance.getToken();
  log('registrationToken: $registrationToken');

  if (shouldUseFirebaseEmulator) {
    await auth.useAuthEmulator('localhost', 9099);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Standard Demo',
      // home: MyHomePage(title: 'Flutterwave Standard'),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    var navigator = Navigator.of(context);

    String email = emailController.text.trim();
    String password = passwordController.text;
    log('User: $email $password');
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        navigator.push(MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (err) {
      log('Error: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loging in: $err'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void googleLogin() async {
    var navigator = Navigator.of(context);

    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      log('googleSiginInAccount: $googleSignInAccount');
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      UserCredential userCredential = await auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleSignInAuthentication.idToken,
              accessToken: googleSignInAuthentication.accessToken));

      if (userCredential.user != null) {
        getUserProfile(googleSignInAccount.id);

        await sendNotification(googleSignInAccount);

        navigator.push(MaterialPageRoute(
            builder: (context) => HomePage(uid: googleSignInAccount.id)));
      }
    } on Exception catch (err) {
      log('Error: $err');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loging in: $err'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // initializeFirebase();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  hintText: 'Email',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  hintText: 'Password',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
                onPressed: () {
                  googleLogin();
                },
                icon: const Icon(FlutterIcons.google__with_circle_ent),
                label: const Text('Google sign In')),
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
