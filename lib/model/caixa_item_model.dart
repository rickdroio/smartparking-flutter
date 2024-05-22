import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CaixaItem {
  String id;
  String caixaId;
  String formaPgto;
  double valorTotal;

  CaixaItem({this.id, this.caixaId, this.formaPgto, this.valorTotal});

  //transformar DOC firebase no modelo
  static CaixaItem of (String caixaId, DocumentSnapshot doc) {
    return new CaixaItem(
      id: doc.documentID,
      caixaId: caixaId,
      formaPgto: doc.data['formaPgto'],
      valorTotal: doc.data['valorTotal'],
    );
  }  

  String getvalorTotal() {
    return NumberFormat.currency(
      decimalDigits: 2,
      locale: 'pt_br',
      symbol: 'R\$'
    ).format(valorTotal);
  }      
}