import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:nfc_demo/pages/widgets/dialog.dart';

class EmulationNfcPage extends StatefulWidget {
  const EmulationNfcPage({super.key});

  @override
  State<EmulationNfcPage> createState() => _EmulationNfcPageState();
}

class _EmulationNfcPageState extends State<EmulationNfcPage> {
  final _flutterNfcHcePlugin = FlutterNfcHce();
  bool emulating = false;
  dynamic val;
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    stopEmulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emulate NFC"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !emulating
                ? TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter a text',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Column(
                    children: [
                      Image.asset(
                        'assets/nfc_emulation.gif',
                        fit: BoxFit.cover,
                      ),
                      const Text("Emulating")
                    ],
                  ),
            ElevatedButton(
              onPressed: () async {
                if (emulating) {
                  stopEmulation();
                } else {
                  startEmulation();
                }
              },
              child: Text(emulating ? "Stop emulation" : "Start emulation"),
            ),
          ],
        ),
      ),
    );
  }

  startEmulation() async {
    // var content = {
    //   "username": "Test",
    //   "id": 01,
    //   "dateTime": DateTime.now().toLocal(),
    // }; example
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid value"),
        ),
      );
    } else {
      await _flutterNfcHcePlugin.startNfcHce(controller.text).then((value) {
        setState(() {
          val = value ?? "no value";
          emulating = true;
        });
      }).onError((err, stacktrace) {
        //handle error
        setState(() {
          val = err;
        });
        stopEmulation();
        setState(() {
          emulating = false;
        });
        dialog(context, "Error:${err.toString()}");
      });
    }
  }

  stopEmulation() async {
    await _flutterNfcHcePlugin.stopNfcHce();
  }
}
