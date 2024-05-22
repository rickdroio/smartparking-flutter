import 'package:flutter/material.dart';
import '../model/caixa_model.dart';

//enum FormaPgto {dinheiro, cheque, cartao}

class SelectFormaPgtoDialog {

  Future<String> dialog(BuildContext context) async {

    String result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione forma de pgto'),
            content: _renderInitial(context),
          );
        },
      ); 

    return result == null ? '' : result;     
  }

  Widget _renderInitial(BuildContext context) {
    List<Widget> result = List<Widget>();

    formasPgto.forEach((formaPgto) {
      result.add(
        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text(formaPgto),
          onTap: () {
            Navigator.of(context).pop(formaPgto);
          },
        ),    
      );
    });

    return Container(child: Column(children: result));
  }

}