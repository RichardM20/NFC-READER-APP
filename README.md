# LECTURA DE DATOS Y ESCRITURA CON NFC

Este proyecto es algo sencillo con el fin de entender un poco el funcionamiento 
de envio y lectura de datos con nfc
para ello usaremos el plugin: [nfc_manager](https://pub.dev/packages/nfc_manager),

## Informacion

En el archivo main.dart encontraremos todas las clases y funciones hechas.
Si, se que quiza sea un poco enrredado ya que no utilizare ninguna arqitctura o gestor de estados.
Me intersa mas explicar el funcionamiento, por lo que dejare esos detalles de lado y se har a la antiguita con StateFulWidget y setState :3
Pero puedes aplicar sin ningun problema la funcionalidad segun tu necesidad.

Antes de continuar, hay que tener en cuenta que los telefonos que no cuenten con nfc no podran utilizar la aplicacion si se desa subir a las tiendas, ya que GooglePlay indicara que la version no es compatible con el dispositivo.
> Si al igual que yo en su momento intentas leer informacion de una tarjeta de banco, debito o credito dejame decirte que no podras a menos que cuentes con algun tipo de convenio con la entidad y te den alguna forma de obtener la informacion devuelta por esta

## Configuracion
- Android: Para ello en nuestro manifest pondremos la siguente linea.
`<uses-permission android:name="android.permission.NFC/>`
- IOS: En el Info.plist
```xml
<key>NFCReaderUsageDescription</key>
<string>Tu mensaje</string>
```
Ademas de eso deberas agregar 
`com.apple.developer.nfc.readersession.felica.systemcodes` y
`com.apple.developer.nfc.readersession.iso7816.select-identifiers`
si es necesario, igual puedes ir a la doc donde encontraras lo necesario y mas exacto en el proyecto que dan de ejemplo.

## Funcionalidad
Separare lo siguiente en secciones para mejor entendimiento.
### Lectura de datos con NFC
1. initService();
```dart
    initService() async {
    await NfcManager.instance.isAvailable().then((value) {
      if (value == false) {
        //aqui si no tiene nfc en su telefono activo se manejara 
        //ya depende de ti
        showMessage("No tiene servicio NFC") //ejemplo
      } else {
        //solo si quieres iniciarla en ese momento
        //puedes almacenar el valor en una variable para iniciar el servicio en donde quieras dependiendo de su valor.
        read();
      }
    });
  }
```
La funcion anterior es la que verificara si tenemos NFC en nuestro telefono.
Si el telefono cuenta con NFC pero lo tiene inactivo retornara un False tal cual como si el telefono no contara con NFC.  
Por lo contrario regresara un true indicando que tiene el servicio activo, si es asi iniciaremos la lectura de tarjetas NFC con el metodo `read()`  
Dejare dos formas
2. read();
```dart
    read()async{
        await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
            final ndef = Ndef.from(tag); 
            if (ndef != null) {
            final message = await ndef.read(); 
            if (message.byteLength > 0) {
                final record = message.records[0];
                final text = String.fromCharCodes(record.payload);
            }
            }
            stop();
        },
        )
    }
    read() async {
        try {
          await NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
            final ndef = Ndef.from(tag);
            if (ndef != null) {
              if (ndef.cachedMessage != null) {
                for (var element in ndef.cachedMessage!.records) {
                final dataText = String.fromCharCodes(element.payload);
                }
              }
            }
          },
        } 
      }
```
Vamos por puntos.
#### Primera forma
- Primero, Iniciamos la lectura de tarjetas NFC utilizando `NfcManager.instance.startSession()`.  
- Segundo, Esto nos regresara un mapa con la informacion de la tarjeta detectada, lo que haremos ahora sera pasarla al modelo `Ndef` utilizando `Ndef.from(tag)`.  
- Tercero, Si la tarjeta NFC es compatible con el estándar NDEF (NFC Data Exchange Format),entonces  se lee el contenido de la tarjeta NFC utilizando `ndef.read()`. Esto puede incluir datos como texto, enlaces u otra información almacenada en la tarjeta.  
- Cuarto,  Si se lee con éxito algún dato de la tarjeta y su longitud es mayor que cero, se extrae el primer registro (En este caso) de los datos leídos utilizando `message.records[0]`, y se convierte en un texto legible mediante `String.fromCharCodes(record.payload)`.

#### Segunda forma del ejemplo
Es basicamente lo mismo solo que en esta manipulamos y obtenemos los datos que mas nos interesan y estos son los que vienen en el key de `cacheMessage` 
lo recorremos para obtener todos los datos que contenga y por ultima pasamos esos datos de bytes a string.


- Y por ultimo finalizamos la lectura de tarjetas NFC con `stop()`  
3. stop()  
```dart
    stop()async{
        await Future<bool> stop() async {
            return await NfcManager.instance.stopSession().then((value) {
            return true;
        }).onError((error, stackTrace) {
            return false;
        });
    }
    }
```
Este metodo es con el cual finalizaremos cada lectura que se haga o este activa en el telefono o app.  


Y listo. Eso seria todo para la lectura de nfc, ahora pasaremos a la escritura de datos en una tarjeta NFC.  

### Escritura de datos
Para ello utilizaremos un solo metodo anterior mente usado pero modificado para poder escribir datos en la tarjeta.
 
1. writeData();
```dart
Future<void> writeData(String contactNumber) async {
    NfcManager nfcManager = NfcManager.instance;
    stop();
    try {
      await nfcManager.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            await ndef.write(NdefMessage([
              NdefRecord.createText(contactNumber),
            ]));
          }
          stop();
        },
      );
    } catch (ex) {
      stop();
    }
  }

 
```
Bien, antes que nada recueda siempre incluir el metodo `stop()`
antes de iniciar lecturas, esto para finalizar una que previamente quedara abierta o este activa y evitar problemas.  

En caso de no tener la instancia global creamos la nueva donde sera necesaria.
Ahora si, explicare lo anterior por puntos.  

- Primero, iniciamos la lectura de tarjetas con `nfcManager.startSession()`.  
- Segundo, Cuando detecte una tarjeta NFC válida, verificamos que esta tarjeta es compatible con el estándar NDEF (NFC Data Exchange Format).  
- Tercero, recuerdas que para leer utilizamos read y y desmembramos los datos hasta sacar lo que necesitamos?
Bueno, para escribir utilizaremos write, para la informacion que queremos pasar
es decir en ese modelo de datos de la etiqueta que acabamos de detectar le escribiremos informacion, para ello el `ndef.write()`.  
Ahora meteremos todo en una lista de tipo `NdefMessage` esta estructura de datos nos permite pasar la informacion de records, en este caso solo pasaremos un unico registro de tipo texto, para ello el `NdefRecord.createText` aunque podrias usar otro de ser necesario, para este ejemplo pasaremos un texto.  

- Y por ultimo, las excepciones las manejas a como prefieras y necesites, mostrar un mensaje, cerrar la pantalla, eso queda en ti.
Pero siempre recuerda detener la lectura con `stop()`
de lo contrario quedara activa y no queremos eso.  

Eso seria todo para escribir datos en una tarjeta nfc.

### Emulacion NFC

Con la ayuda de mi amigo Angel despues de una busqueda extensiva dimos con un buen plugin funcional y muy estable para poder lograr esto, lo malo esque solo es posible en android.
> Nota: No me quejo soy pobre y no tengo Iphone :c
Por lo que iOS, perdonanos pero quedaste por fuera de esto por esta vez.

Aqui como el como funciona haciendo uso del plugin [flutter_nfc_hce](https://pub.dev/packages/flutter_nfc_hce)
Los ajustes necesarios son un poco largo asi que para ello te invito a  navegar y leerla desde su doc.

Primero no encontraremos con dos metodos `startEmulation()` y `stopEmulation()`  
1. startEmulation()
```dart
startEmulation()async{
   await _flutterNfcHcePlugin.startNfcHce('your text plain').then((value) {
        //code here
      }).onError((err, stacktrace) {
        //handle error
      });
}
```
En el metodo anterior no hay mucho que hacer mas que mandar tu dato y definir el tipo de dato, para ello el `mimeType`
En este ejemplo enviaremos un textoPlano que sera el tipo por defecto.
2. stopEmulation()
```dart
stopEmulation()async{
 await _flutterNfcHcePlugin.stopNfcHce();

}
```
En el anterior el metodo que detiene la emulacion y listo.
Con esto podras emular un tag NFC con tu dispositivo para lo que necesites :)



## NOTA
Recuerda tener en cuenta que esto es un ejemplo sencillo del uso del paquete `nfc_manager`  y `flutter_nfc_hce`
Seguramente tendras que hacer algo mas complejo, como validar el tipo de tarjeta que recibes, que se pueda escribir informacion, que sea compatible etc...  

Porque si, hay tarjetas las cuales no se les puede escribir informacion ni leer.  
Pero ya eso es algo que deberas invetigar por ti mismo, espero que esta mini guia de uso haya sido de utilidad si fue asi espero puedas dejar tu estrella para apoyarnos.

> Si quiere colaborar para mejorar  algun proyecto subido o explicacion dada eres bienvendo/a, en mi perfil estan mis redes donde puedes ponerte en contacto conmigo 

