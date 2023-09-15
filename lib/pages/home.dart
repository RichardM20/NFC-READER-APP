import 'package:flutter/material.dart';
import 'package:nfc_demo/pages/amulation_nfc.dart';
import 'package:nfc_demo/pages/write_data_nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'read_data_nfc.dart';
import 'widgets/button.dart';
import 'widgets/dialog.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool avaliableNFC = false;
  @override
  void initState() {
    super.initState();
  }

  initService() async {
    await NfcManager.instance.isAvailable().then((value) {
      if (value == false) {
        setState(() {
          avaliableNFC = false;
        });
        dialog(context, "Not found NFC Service");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: avaliableNFC != true
            ? const Center(
                child: Text(
                  "It seems that your device does not have or does not have the NFC service active",
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
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
                  const SizedBox(height: 10),
                  CustomButtonAction(
                    textButton: "Emulate NFC",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const EmulationNfcPage(),
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
