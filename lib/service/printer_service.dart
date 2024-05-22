import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'configuracoes_local_service.dart';
import 'dart:typed_data';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;


class PrinterService {
  BluetoothDevice _printer;
  var _bluetooth;

  final String _SELECT_BIT_IMAGE_MODE = String.fromCharCodes([0x1B, 0x2A, 33, 0x06, 0x00]);
  final String _PRINT_RASTER_BIT = String.fromCharCodes([0x1D, 0x76, 0x30, 0x00]); //1D763000
  final String _LF = String.fromCharCode(0x0A); //Print and line feed
  final String _SET_LINE_SPACING_30  = String.fromCharCodes([0x1B, 0x33, 30]);
  final String _SET_LINE_SPACING_24  = String.fromCharCodes([0x1B, 0x33, 24]);
  final String _ESC_ALIGN_CENTER = String.fromCharCodes([ 0x1b, 0x61, 0x01 ]);
  final String _ESC_ALIGN_LEFT = String.fromCharCodes([ 0x1b, 0x61, 0x00 ]);
  final String _ESC_ALIGN_RIGHT = String.fromCharCodes([ 0x1b, 0x61, 0x02 ]);
  final String _FEED_LINE = String.fromCharCode(10);


  final List<String> _binaryArray = [ "0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111" ];
  final String _hexStr = "0123456789ABCDEF";

  PrinterService({notLoadPrinter = false}) {
    _initPrintService(notLoadPrinter);
  }  

  bool isConnect() {
    return true;
  }

  static Future<List<BluetoothDevice>> getBluetoothDevices() async {
    final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();      
    } on PlatformException catch(error) {
      print('getBondedDevices');
      print(error);
    } 
    return devices; 
  }

  Future _initPrintService(notLoadPrinter) async {
    //inicia com a impressora configurada em settings
    if (!notLoadPrinter) { // >> parametro usando em cofiguracoes
      BluetoothDevice device = await _getPrinterConfiguracoes();
      setBluetoothDevice(device);
    }
  }

  Future<BluetoothDevice> _getPrinterConfiguracoes() async {
    BluetoothDevice deviceLocated;
    String printerAddress = await ConfiguracoesLocalService.getPrinter();
    List<BluetoothDevice> devices = await getBluetoothDevices();    
    devices.forEach((d) {
      if (d.address == printerAddress) {  
        deviceLocated = d;
      }
    }); 
    return deviceLocated;
  }

  Future setBluetoothDevice(BluetoothDevice device) async {
    if (device == null)
      return Future.error('Nenhuma impressora selecionada!');

    try {
      _printer = device;

      if (! await FlutterBluetoothSerial.instance.isEnabled)
        return connectPrinter(); //se nao estiver conectado, conectar!
        
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future connectPrinter() async {
    print('called connectPrinter()');
    try {
      if (_printer == null ) {
        return Future.error('Nenhuma impressora selecionada');
      }
      else {
        print('connecting to ${_printer.name} | ${_printer.address}');
        BluetoothConnection connection = await BluetoothConnection.toAddress(_printer.address);


        Future<dynamic> c = FlutterBluetoothSerial.instance.connect(_printer);
        await Future.delayed(Duration(seconds: 2), () => {}); //delay entre conectar & começar a usar a impressora
        return c;
      }
    }
    catch(e) {
      //print('PlatformException - ACHOU ERRORXX ${e.message}');
      return Future.error('Erro ao conectar a impressora');
    }
  }

  Future disconectPrinter() async {
    print('desconectando BT...');
    await _bluetooth.disconnect();
  }

  Future _writePrinter(String text) async {
    try {
      //bool isOn = await bluetooth.isOn;
      //print('isOn: $isOn');
      _bluetooth.write(text);
    } catch (e) {
      print('error: ${e.toString()}');
    }   
  }

  Future printText({String msg, int size = 0, int align = 0}) async {
    print('printText = $msg');
    String cc = String.fromCharCodes([0x1B,0x21,0x03]); //0- normal size text
    String bb = String.fromCharCodes([0x1B,0x21,0x08]); //1- only bold text
    String bb2 = String.fromCharCodes([0x1B,0x21,0x20]); //2- bold with medium text
    String bb3 = String.fromCharCodes([0x1B,0x21,0x10]); //3- bold with large text  

    switch (size){
      case 0:
        _writePrinter(cc);
        break;
      case 1:
        _writePrinter(bb);
        break;
      case 2:
        _writePrinter(bb2);
        break;
      case 3:
        _writePrinter(bb3);
        break;
    }

    switch (align){
      case 0:
        //left align
        _writePrinter(_ESC_ALIGN_LEFT);
        break;
      case 1:
        //center align
        _writePrinter(_ESC_ALIGN_CENTER);
        break;
      case 2:
        //right align
        _writePrinter(_ESC_ALIGN_RIGHT);
        break;
    }

    await _writePrinter(msg);
    await _writePrinter(_LF);
  }

  //http://toanbily.blogspot.com/2010/04/sending-bit-image-to-epson-tm-t88iii.html
  //https://stackoverflow.com/questions/14530058/how-can-i-print-an-image-on-a-bluetooth-printer-in-android?noredirect=1&lq=1
  //https://pos-x.com/download/escpos-programming-manual/

  Future printQRCode(String data) async {
    QrPainter painter = QrPainter(
      data: data,
      version: 2, //capacidade
      emptyColor: const ui.Color(0xffffffff)
    );

    final ByteData imageData = await painter.toImageData(210, format: ui.ImageByteFormat.png);
    final buffer = imageData.buffer;
    var listIBytes = buffer.asUint8List();
    img.Image image = img.decodeImage(listIBytes);

    await _printImage(image);
  }

  Future feedLine() async {    
    //_writePrinter(_FEED_LINE);
    await _writePrinter(_FEED_LINE);
  }

  Future _printImage(img.Image image) async {
    List<String> commandList = List<String>();

    commandList.add('1D763000'); //PRINT_RASTER_BIT = [0x1D, 0x76, 0x30, 0x00];
    
    String wHexString = _getTamanhoHex(image.width, true);
    commandList.add(wHexString);
    String hHexString = _getTamanhoHex(image.width, false);
    commandList.add(hHexString);

    List<String> dots = _convertToMonochrome(image);
    List<String> hexList = _binaryListToHexStringList(dots);  
    commandList.add(hexList.join());

    List<int> bytes = _hexStringToBytes(commandList.join());
    await _writePrinter(_ESC_ALIGN_CENTER);
    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
    feedLine();
  }

  List<String> _convertToMonochrome(img.Image image) {
    List<String> listTotal = List<String>();
    //matrix tamanho W x H, porém completar de ZEROS para dar qnt de bytes correta
    int zeroCount = image.width % 8;
    String zeroStr = "";
    if (zeroCount > 0) {
      for (int i = 0; i < (8 - zeroCount); i++) {
        zeroStr = zeroStr + "0";
      }      
    }

    for (var y = 0; y < image.height; y++) {
      List<String> linha = List<String>();
      for (var x = 0; x < image.width; x++) {   

        int color = image.getPixel(x, y);
        //print('getPixel ${x.toString()}, ${y.toString()} = ${color.toString()}');      
        int r = img.getRed(color);
        int g = img.getGreen(color);
        int b = img.getBlue(color);
        //print('${r.toString()}, ${g.toString()}, ${b.toString()}');

        // if color close to white，bit='0', else bit='1'
        if (r > 160 && g > 160 && b > 160)
            linha.add('0');
        else
            linha.add('1');
      }
      
      if (zeroCount > 0) linha.add(zeroStr);
      
      listTotal.add(linha.join()); 
    }

    return listTotal;
  }  

  List<String> _binaryListToHexStringList(List<String> binaryList) {
    //converte lista de binarios para hexa, a cada 8bits
    List<String> hexList = List<String>();
    String binaryStr = binaryList.join();

    for (int i = 0; i < binaryStr.length; i += 8) {
      String str = binaryStr.substring(i, i + 8);
      String hexString = _binaryToHex(str);
      //int hex = int.parse("0x$hexString");
      //print('$str = ${hex.toString()}');
      hexList.add(hexString);
    }
    //print(hexList.join());
    return hexList;
  }

  String _binaryToHex(String binaryStr) {
    //encontra padrão de 4 bits no array binaryArray
    //utilizando mesmo indice, pega o valor em hex representante
    String f4 = binaryStr.substring(0, 4);
    String b4 = binaryStr.substring(4, 8);

    int hexf4 = _binaryArray.indexOf(f4);
    int hexb4 = _binaryArray.indexOf(b4);
    
    return _hexStr[hexf4] + _hexStr[hexb4];
  }    

  String _getTamanhoHex(int tam, bool isWidth) {
    //Raster Image - xL e xH - tamanho horizontal
    //tamanho W ou H tem tam max de 2 bytes
    if (tam > 65535) { //imprime apenas max 2 Bytes de tamanho (FFFF = 65535)
      throw Exception('width is too large');
    } 

    int x;
    if (isWidth) 
      x = tam % 8 == 0 ? tam ~/8 : (tam ~/8 + 1);
    else
      x = tam;
           
    var byte1 = x & 0xff;
    var byte2 = (x >> 8) & 0xff;
    
    String sbyte1 = byte1.toRadixString(16);
    if (sbyte1.length == 1)
      sbyte1 = '0' + sbyte1;

    String sbyte2 = byte2.toRadixString(16);
    if (sbyte2.length == 1)
      sbyte2 = '0' + sbyte2;    

    return '$sbyte1$sbyte2';
  }  

  List<int> _hexStringToBytes(String hexString) {
    if (hexString == null || hexString == "") {
        return null;
    }

    String hString = hexString.toUpperCase();
    int len = hString.length ~/ 2; //para cada 2 hexas = 1byte
    List<int> bytes = List<int>();
    for (int i = 0; i < len; i++) {
      int pos = i * 2;
      int b = _charToByte(hString[pos]) << 4 | _charToByte(hString[pos+1]);
      bytes.add(b);
    }

    return bytes;
  }

  int _charToByte(String c) {
    return '0123456789ABCDEF'.indexOf(c);
  }

}
