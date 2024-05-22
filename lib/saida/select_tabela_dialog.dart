import 'package:flutter/material.dart';
import '../model/tabela_model.dart';

class SelectTabelaDialog {

  final List<Tabela> tabelas;
  SelectTabelaDialog(this.tabelas);

  Future<String> dialog(BuildContext context) async {

    String result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione tabela de preço'),
            content: _renderInitial(context),
          );
        },
      ); 

    return result == null ? '' : result;     
  }

  Widget _renderInitial(BuildContext context) {
    List<Widget> result = List<Widget>();

    tabelas.forEach((tabela) {
      result.add(
        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text(tabela.nomeTabela),
          onTap: () {
            Navigator.of(context).pop(tabela.id);
          },
        ),    
      );
    });

    return Container(child: Column(children: result));
  }

}