import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import './assinatura_service.dart';
import 'package:device_info/device_info.dart';
import './usuario_service.dart';

class DeviceService {

  static const String dbPath = 'devices';

  static Future setNewDevice() async {
    print('setNewDevice()');
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    String uid = await UsuarioService.getFirebaseUid();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    ref.collection(dbPath).document().setData({
      'uid': uid,
      'datetime': DateTime.now(),
      'id': androidInfo.id,
      'androidId': androidInfo.androidId,
      'model': androidInfo.model,
      'device': androidInfo.device,
      'manufacturer': androidInfo.manufacturer,
      'codename': androidInfo.version.codename,
      'sdkInt': androidInfo.version.sdkInt,
    });
  }

  static Future<Query> getDeviceRef() async {  
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    String uid = await UsuarioService.getFirebaseUid();
    print('getDeviceRef UID $uid');
    return ref.collection(dbPath).where('uid', isEqualTo: uid).orderBy('datetime', descending: true).limit(1);
  }

  static Future<String> androidId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.androidId;
  }


}