import 'package:flutter/material.dart';

import 'scan_nfc.dart';
import 'widgets/custom_btn.dart';
import 'write_nfc.dart';

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
                  builder: (ctx) => const ScanNFCpage(),
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

//interfaz para la escritura de datos que enviaremos con nfc
