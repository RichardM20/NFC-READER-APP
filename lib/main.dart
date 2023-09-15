import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:svg_flutter/svg.dart';

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
    //en caso de que haya una lectura activa la detenemos
    stop();
    //metodo para iniciar el escaneo de nfc
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        //se pasan los datos y detiene la animacion de escaneo
        //la informacion con los datos sera tratada dependiendo de la necesida

        setState(() {
          data = tag.data;
          scaning = false;
          handleData = tag.handle;
        });
        final ndef = Ndef.from(tag); //parseamos
        if (ndef != null) {
          //verificamos que no sea nula ya que si es puede que no sea compatible
          final message =
              await ndef.read(); //obtenemos el mensaje de byts que nos regresa
          if (message.byteLength > 0) {
            //verifucamos que no sea nulo
            final record = message.records[
                0]; //en este caso tengo una instancia en la lista de bytes con datos
            final text = String.fromCharCodes(record.payload);
            setState(() {
              textDecode = text;
            });
          }
        }
        print(data);
        //se detiene la lectura al capturar una tarjeta
        stop();
      },
    ).onError((error, stackTrace) {
      stop();
      setState(() {
        scaning = false;
        data = error.toString();
      });

      //en caso de error
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
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
        return showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
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

//interfaz para la escritura de datos que enviaremos con nfc

class WriteDataNfcPage extends StatefulWidget {
  const WriteDataNfcPage({Key? key}) : super(key: key);

  @override
  _WriteDataNfcPageState createState() => _WriteDataNfcPageState();
}

class _WriteDataNfcPageState extends State<WriteDataNfcPage> {
  final TextEditingController _contactNumberController =
      TextEditingController();
  bool scaning = false;
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
      return showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
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
}

class CustomButtonAction extends StatelessWidget {
  const CustomButtonAction({
    super.key,
    required this.textButton,
    this.onTap,
  });
  final Function()? onTap;
  final String textButton;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 1,
              offset: const Offset(-0.0, -0.0),
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/nfc_icon.svg',
              color: Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(
              textButton,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
