import 'package:cloud_firestore/cloud_firestore.dart';

class Convite {

  String id;
  String nome;
  String telefone;
  String assinatura;
  String estacionamento;
  bool ativo;

  Convite({this.id, this.nome, this.telefone, this.assinatura, this.estacionamento, this.ativo});

  static Convite of (DocumentSnapshot doc) {
    return new Convite(
      id: doc.documentID,
      nome: doc.data['nome'],
      telefone: doc.data['telefone'],
      assinatura: doc.data['assinatura'],
      estacionamento: doc.data['estacionamento'],
      ativo: doc.data['ativo'],
    );
  }

}