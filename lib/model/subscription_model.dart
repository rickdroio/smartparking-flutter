import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Subscription {
  final String sku;
  final String nome;
  String periodo;
  final int qtdeEstacionamentos;
  final String descricao;
  
  String preco;
  DateTime dataInicio;
  DateTime dataFim;
  String detalhes;

  bool ativo;
  ProductDetails productDetails;

  Subscription({this.ativo, this.sku, this.nome, this.periodo, this.qtdeEstacionamentos, this.descricao, this.preco});

  String getDataInicio(){
    return DateFormat('dd-MM-yyyy').format(dataInicio);
  }
  String getDataFim(){
    return DateFormat('dd-MM-yyyy').format(dataFim);
  }

  static Subscription of(DocumentSnapshot doc) {  
    return Subscription(
      sku: doc.documentID,
      descricao: doc.data['descricao'],
      nome: doc.data['nome'],
      qtdeEstacionamentos: doc.data['qtdeEstacionamentos'] ?? 0,
      periodo: doc.data['periodo'],
    );
  }

}
