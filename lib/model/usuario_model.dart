import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './estacionamento.dart';

class Usuario {

  String id;
  bool admin;
  String nome;
  String telefone;
  String email;

  List<Estacionamento> estacionamentosObject;

  Usuario({this.id, this.admin, this.nome, this.telefone, this.email});

  static Usuario of (DocumentSnapshot doc) {
    return new Usuario(
      id: doc.documentID,
      admin: doc.data['admin'] ?? false,
      nome: doc.data['nome'],
      telefone: doc.data['telefone'],
      email: doc.data['email'],
    );
  }  

  Widget getUserAvatar() {
    bool _admin = admin ?? false;
    return Container(width: 50, height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(nome[0]),
          ),
          Align(alignment: Alignment.bottomRight, child: _admin ? Icon(Icons.star, color: Colors.yellow) : Icon(Icons.bookmark, color: Colors.yellow)) 
        ]
      )
    );
  }

}