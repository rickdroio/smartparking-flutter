import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/utils.dart';

class PromoService {

  static Future<bool> checkPromo(String promoCode) async {
    DocumentSnapshot doc = await Firestore.instance.collection('promo').document(promoCode).get();

    if (doc.exists) {
      int qty = doc.data['qty'];
      int used = doc.data['used'];
      DateTime expireDate = Utils.timeStampToDateTime(doc.data['expireDate']);
      DateTime data = DateTime.now();

      return (data.isBefore(expireDate) && used < qty);
    }
    else {
      return false;
    }

  }

}