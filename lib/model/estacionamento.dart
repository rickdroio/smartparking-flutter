import 'package:cloud_firestore/cloud_firestore.dart';

class Estacionamento {

  String id;
  String endereco;
  String nome;
  int capacidade;
  int totalEntradasAberto;
  bool ativo;
  List<String> usuarios;

  Estacionamento({this.id, this.endereco, this.nome, this.usuarios, this.capacidade, this.totalEntradasAberto, this.ativo});

  static Estacionamento of (DocumentSnapshot doc) {
    if (doc.exists)
      return Estacionamento(
        id: doc.documentID,
        endereco: doc.data['endereco'],
        nome: doc.data['nome'],
        capacidade: doc.data['capacidade'],
        totalEntradasAberto: doc.data['totalEntradasAberto'],
        ativo: doc.data['ativo'],
        usuarios: doc.data['usuarios'] == null ? List<String>() : List<String>.from(doc.data['usuarios'])
      );
    else return null;
  }  

  bool isAtivo() {
    return ativo ?? false;
  }
}