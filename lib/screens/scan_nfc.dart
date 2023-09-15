import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ScanNFCpage extends StatefulWidget {
  const ScanNFCpage({super.key});

  @override
  State<ScanNFCpage> createState() => _ScanNFCpageState();
}

class _ScanNFCpageState extends State<ScanNFCpage> {
  bool scaning = true;
  bool avaliableNFC = false;
  dynamic data;
  dynamic handleData;
  dynamic textDecode;

  read() async {
    stop();
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        setState(() {
          data = tag.data;
          scaning = false;
          handleData = tag.handle;
        });
        final ndef = Ndef.from(tag); //parseamos
        String text = '';
        if (ndef != null) {
          if (ndef.cachedMessage != null) {
            for (var element in ndef.cachedMessage!.records) {
              debugPrint(" PLAYLOAD - ${String.fromCharCodes(element.payload)}");
              text = String.fromCharCodes(element.payload).replaceAll('en', '').trim();
            }
          }

          setState(() {
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

      //en caso de error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ok"),
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    stop();

    //se detiene al salir de la pantalla
    super.dispose();
  }

  @override
  void initState() {
    initService();
    super.initState();
  }

  initService() async {
    //este metodo nos retornara un valor verdadero o falso
    //en caso de que sea verdadero es que tenemos nfc en nuestro dispositivo
    //de lo contrario es porque no se tiene nfc o no esta activo
    await NfcManager.instance.isAvailable().then((value) {
      if (value == false) {
        setState(() {
          avaliableNFC = false;
        });
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Not found NFC Service"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          ),
        );
      } else {
        //en caso de que este disponible
        //iniciamos la lectura
        read();
        setState(() {
          avaliableNFC = true;
        });
      }
    });
  }

  Future<bool> stop() async {
    //metodo para detener la lectura de nfc
    return await NfcManager.instance.stopSession().then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });
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
        child: avaliableNFC == true
            ? scaning == true
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
}
