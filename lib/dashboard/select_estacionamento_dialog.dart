import 'package:flutter/material.dart';
import '../model/estacionamento.dart';

class SelectEstacionamentoDialog {

  final List<Estacionamento> estacionamentos;
  SelectEstacionamentoDialog(this.estacionamentos);

  Future<String> dialog(BuildContext context) async {

    String result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione estacionamento ativo'),
            content: _renderInitial(context),
          );
        },
      ); 

    return result == null ? '' : result;     
  }

  Widget _renderInitial(BuildContext context) {
    List<Widget> result = List<Widget>();

    estacionamentos.forEach((tabela) {
      result.add(
        ListTile(
          leading: Icon(Icons.place),
          title: Text(tabela.nome),
          onTap: () {
            Navigator.of(context).pop(tabela.id);
          },
        ),    
      );
    });

    return Container(child: Column(children: result));
  }

}