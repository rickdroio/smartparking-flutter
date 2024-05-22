import 'package:flutter/services.dart';
import 'dart:async';

//import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:android_device_info/android_device_info.dart';

class NfcService {

  static Future<bool> supportsNFC() async {
    var nfcInfo = await AndroidDeviceInfo().getNfcInfo();
    return (nfcInfo['isNfcPresent'] ?? false);
  }

  static Future<bool> isNFCEnable() async {
    Map<String, bool> nfcInfo = await AndroidDeviceInfo().getNfcInfo();
    return (nfcInfo['isNfcEnabled'] ?? false);
  }  

  static Stream<String> readNFC() {
   // return FlutterNfcReader.read;
  } 

  static Stream<String> writeNFC(String id) {
    //return FlutterNfcReader.writeToCard(id);
  }

  static Future<void> stopNFC() async {
    /*
    try {
      print('NFC: STOP');
      await FlutterNfcReader.stop;
    } on PlatformException {
      print('NFC: Stop scan exception');
    } */
  }  

}