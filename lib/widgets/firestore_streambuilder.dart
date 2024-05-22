import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStreamBuilder extends StatefulWidget {

  final Stream<QuerySnapshot> stream;
  final Function widgetCallback; 

  FirestoreStreamBuilder(this.stream, this.widgetCallback);

  @override
    State<StatefulWidget> createState() {
      return _MyStreamBuilder();
    }

}

class _MyStreamBuilder extends State<FirestoreStreamBuilder> {

  
  Widget mensagem(String texto) {
    return Center(
      child: Container(
        alignment: Alignment(0.0, 0.0),
        child: Text(texto),
        constraints: BoxConstraints(minHeight: 150.0)
      ),
    );
  }

  @override
    Widget build(BuildContext context) {

      return StreamBuilder<QuerySnapshot>(
        stream: widget.stream,
        builder: (context, snapshot) {

          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

          switch (snapshot.connectionState) {
            case ConnectionState.none: return mensagem('Nada selecionado');
            case ConnectionState.waiting: return mensagem('Carregando...');
            default: {
              if (snapshot.data.documents.length <= 0 ) {
                return mensagem('nenhuma informação');
              }
              else {
                return widget.widgetCallback(snapshot);
              }             
            }
          }
        }
      );
    }

}