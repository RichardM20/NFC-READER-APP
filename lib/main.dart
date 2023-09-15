import 'package:flutter/material.dart';
import 'pages/read_data_nfc.dart';
import 'pages/widgets/button.dart';
import 'pages/write_data_nfc.dart';

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

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButtonAction(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const ReadNfcPage(),
                ),
              ),
              textButton: "Scann NFC",
            ),
            const SizedBox(height: 10),
            CustomButtonAction(
              textButton: "Send data NFC",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const WriteDataNfcPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 
