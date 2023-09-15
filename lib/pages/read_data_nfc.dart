import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  void initState() {
    initService();
    super.initState();
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
        child: avaliableNFC == true //si es valido se muestra la interfaz
            ? scaning == true // si esta escaneando se muestra la animacion
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
                  )
            : const Center(
                child: Text(
                  "It seems that your device does not have or does not have the NFC service active",
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }

  initService() async {
    await NfcManager.instance.isAvailable().then((value) {
      if (value == false) {
        setState(() {
          avaliableNFC = false;
        });
        dialog("Not found NFC Service");
      } else {
        read();
        setState(() {
          avaliableNFC = true;
        });
      }
    });
  }

  Future<bool> stop() async {
    return await NfcManager.instance.stopSession().then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });
  }

  read() async {
    stop();
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag); //parseamos
        if (ndef != null) {
          final message = await ndef.read();
          if (message.byteLength > 0) {
            final record = message.records[0];
            final text = String.fromCharCodes(record.payload);
            setState(() {
              data = tag.data; //informacion capturada sin formato
              scaning = false; //indicador de animacion
              handleData = tag.handle;
              textDecode = text; //text formatead
            });
          }
        }
        stop();
      },
    ).onError((error, stackTrace) {
      stop();
      setState(() {
        scaning = false;
        data = error.toString();
      });
      dialog(error.toString());
    });
  }

  dialog(String e) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("Error"),
        content: Text(e),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
          )
        ],
      ),
    );
  }
}
