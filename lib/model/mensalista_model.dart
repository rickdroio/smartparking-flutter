import 'package:cloud_firestore/cloud_firestore.dart';

class Mensalista {

  String id;
  String nome;
  String placa;
  String modelo;

  Mensalista({this.id, this.nome, this.placa, this.modelo});

  static Mensalista of (DocumentSnapshot doc) {
    print('MENSALISTA DOC EXISTS = ${doc.exists.toString()}');
    if (doc.exists)
      return Mensalista(
        id: doc.documentID,
        nome: doc.data['nome'],
        placa: doc.data['placa'],
        modelo: doc.data['modelo'],
      );
    else return null;
  }  
}