import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'configuracoes_local_service.dart';
import 'dart:typed_data';
import 'dart:convert';



class PrinterService {

  BluetoothConnection connection;

  Future connect({String address}) async {
    if (connection != null) print('connection != null');
    try {
      String printerAddress;
      if (address == null)
        printerAddress = await ConfiguracoesLocalService.getPrinter();
      else
        printerAddress = address;
      //print('connecting to $printerAddress');

      connection = await BluetoothConnection.toAddress(printerAddress);
      print('Connected to the device');

      connection.input.listen((data) {
        print('Data incoming: ${ascii.decode(data)}');
      }).onDone(() {
        print('Disconnected by remote request');
      });

      //FlutterBluetoothSerial.instance.removeDeviceBondWithAddress
    }
    catch (exception) {
      print('Cannot connect, exception occured');
      print(exception.toString());
    }    
  }

  Future disconnect() {
    print('disconnecting...');
    return connection.finish();
  }

  bool get isConnected => connection != null && connection.isConnected;

  void write(String text) {
    connection.output.add(utf8.encode(text));
  }
  

}