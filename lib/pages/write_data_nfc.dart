import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteDataNfcPage extends StatefulWidget {
  const WriteDataNfcPage({Key? key}) : super(key: key);

  @override
  _WriteDataNfcPageState createState() => _WriteDataNfcPageState();
}

class _WriteDataNfcPageState extends State<WriteDataNfcPage> {
  final _contactNumberController = TextEditingController();
  bool scaning = false;

  @override
  void dispose() {
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send data NFC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: scaning == true
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final contactNumber = _contactNumberController.text;
                        if (contactNumber.isNotEmpty) {
                          await writeData(contactNumber);
                          // ignore: use_build_context_synchronously
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid value"),
                            ),
                          );
                        }
                      },
                      child: const Text("Send data with NFC"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> writeData(String contactNumber) async {
    NfcManager nfcManager = NfcManager.instance;
    stop();
    try {
      setState(() {
        scaning = true;
      });
      await nfcManager.startSession(
        alertMessage: 'Detected',
        onDiscovered: (NfcTag tag) async {
          //iniciamos lectura para el envio
          //cuando detecte el nfc lo parseamos
          //y procedemos a escribirle los datos
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            await ndef.write(NdefMessage([
              NdefRecord.createText(contactNumber),
            ]));
          }
          setState(() {
            scaning = false;
          });
          stop();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Success: $contactNumber"),
            ),
          );
        },
      );
    } catch (ex) {
      stop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar datos: ${ex.toString()}"),
        ),
      );
    }
  }

  stop() async {
    await NfcManager.instance.stopSession();
  }
}
