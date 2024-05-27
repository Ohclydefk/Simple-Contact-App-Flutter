import 'dart:io';
import './Final Project/contact_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_clyde/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Initialize Firebase before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secret Heaven',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 67, 136, 233)),
        useMaterial3: false,
      ),
      home: const ContactLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
