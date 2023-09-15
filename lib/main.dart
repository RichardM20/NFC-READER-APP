import 'package:flutter/material.dart';
import 'package:nfc_demo/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NFC Demo App',
      debugShowCheckedModeBanner: false,
      home: InitialPage(),
    );
  }
}
