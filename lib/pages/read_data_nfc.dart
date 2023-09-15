import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_demo/pages/widgets/dialog.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ReadNfcPage extends StatefulWidget {
  const ReadNfcPage({super.key});

  @override
  State<ReadNfcPage> createState() => _ReadNfcPageState();
}

class _ReadNfcPageState extends State<ReadNfcPage> {
  bool scaning = true;
  bool avaliableNFC = false;
  dynamic data;
  dynamic handleData;
  dynamic textDecode;
  final nfcInstance = NfcManager.instance;
  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text("NFC Demo "),
      ),
      body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: scaning == true // si esta escaneando se muestra la animacion
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Scaning, Please approach your card",
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      child: Lottie.asset(
                        'assets/nfc-animation.zip',
                        animate: true,
                      ),
                    ),
                  ],
                )
              : Text(
                  "decode message:$textDecode\n\nData captured: $data\nhandle data: $handleData",
                )),
    );
  }

  Future<bool> stop() async {
    return await nfcInstance.stopSession().then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });
  }

  read() async {
    stop();
    await nfcInstance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag); //parseamos
        String text = '';
        if (ndef != null) {
          if (ndef.cachedMessage != null) {
            for (var element in ndef.cachedMessage!.records) {
              text = String.fromCharCodes(element.payload);
            }
          }
          setState(() {
            data = tag.data;
            scaning = false;
            handleData = tag.handle;
            textDecode = text;
          });
        }

        stop();
      },
    ).onError((error, stackTrace) {
      stop();
      setState(() {
        scaning = false;
        data = error.toString();
      });
      dialog(context, error.toString());
    });
  }
}
