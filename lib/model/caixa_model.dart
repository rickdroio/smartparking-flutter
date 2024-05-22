import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../shared/utils.dart';

final List<String> formasPgto = ['Dinheiro', 'Cheque', 'Cartão'];

class Caixa {
  String id;
  DateTime dataAbertura;
  DateTime dataFechamento;
  double valorInicial;
  double valorTotal;
  bool caixaFinalizado;

  Caixa({this.id, this.dataAbertura, this.dataFechamento, this.valorInicial, this.valorTotal, this.caixaFinalizado});

  //transformar DOC firebase no modelo
  static Caixa of (DocumentSnapshot doc) {
    return new Caixa(
      id: doc.documentID,
      dataAbertura: Utils.timeStampToDateTime(doc.data['dataAbertura']),
      dataFechamento: Utils.timeStampToDateTime(doc.data['dataFechamento']),
      valorInicial: doc.data['valorInicial'],
      valorTotal: doc.data['valorTotal'],
      caixaFinalizado: doc.data['caixaFinalizado'],
    );
  }    

  String getdataAbertura(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataAbertura);
  }  

  String getdataFechamento(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataFechamento);
  } 

  String getvalorTotal() {
    return NumberFormat.currency(
      decimalDigits: 2,
      locale: 'pt_br',
      symbol: 'R\$'
    ).format(valorTotal);
  }  

}