// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutterwavepayment/main.dart';

// bool shouldUseFirebaseEmulator = false;

// late final FirebaseApp app;
// late final FirebaseAuth auth;

// class AuthPage extends StatelessWidget {
//   const AuthPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Firebase Example App',
//       theme: ThemeData(primarySwatch: Colors.amber),
//       home: Scaffold(
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             return Row(
//               children: [
//                 Visibility(
//                   visible: constraints.maxWidth >= 1200,
//                   child: Expanded(
//                     child: Container(
//                       height: double.infinity,
//                       color: Theme.of(context).colorScheme.primary,
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Firebase Auth Desktop',
//                               style: Theme.of(context).textTheme.headlineMedium,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: constraints.maxWidth >= 1200
//                       ? constraints.maxWidth / 2
//                       : constraints.maxWidth,
//                   child: StreamBuilder<User?>(
//                     stream: auth.authStateChanges(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         return const HomePage();
//                         // return const ProfilePage();
//                       }
//                       return const AuthPage();
//                       // return const AuthGate();
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
