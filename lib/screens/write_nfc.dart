import 'package:flutter/material.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteDataNfcPage extends StatefulWidget {
  const WriteDataNfcPage({Key? key}) : super(key: key);

  @override
  WriteDataNfcPageState createState() => WriteDataNfcPageState();
}

class WriteDataNfcPageState extends State<WriteDataNfcPage> {
  final TextEditingController _contactNumberController = TextEditingController();
  bool scaning = false;
  bool _showNFCScanDialog = false;

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
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error al enviar los datos\n$ex"),
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

  stop() async {
    await NfcManager.instance.stopSession();
  }

  @override
  void dispose() {
    _contactNumberController.dispose();
    _onCloseButtonPressed();
    super.dispose();
  }

  final _flutterNfcHcePlugin = FlutterNfcHce();
  void _onScanButtonPressed() async {
    var content = 'Prueba de Scan 1.0';
    var result = await _flutterNfcHcePlugin.startNfcHce(content);

    debugPrint('---------------------------------->${result!}');

    setState(() {
      _showNFCScanDialog = true;
    });
  }

  void _onCloseButtonPressed() async {
    await _flutterNfcHcePlugin.stopNfcHce();

    setState(() {
      _showNFCScanDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send data NFC'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onScanButtonPressed,
        child: const Text("NFC"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            // Background widget
            Container(
                color: Colors.transparent,
                child: const Center(
                    child: Column(
                  children: [Text("NFC")],
                ))),

            // NFC Scan Dialog
            if (_showNFCScanDialog)
              GestureDetector(
                onTap: _onCloseButtonPressed,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/nfc_tag.png', width: 100, height: 100),
                      const SizedBox(height: 16),
                      const Text(
                        'Start Nfc Hce',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
