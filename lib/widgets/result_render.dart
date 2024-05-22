import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ResultRender {

  static Widget _renderMessage(Color cor, IconData icone, String mensagem) {
    return Container(
      decoration: new BoxDecoration(color: cor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[ 
          Center(child: Column(children: <Widget>[
            Icon(icone, size: 96.0, color: Colors.white),
            SizedBox(height: 25),
            Text(mensagem, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
          ]))
        ],
      ),
    );
  }

  static Widget renderSuccess(String mensagem){
    return _renderMessage(Colors.green, MdiIcons.checkboxMarkedCircle, mensagem);
  }

  static Widget renderFail(String mensagem){
    return _renderMessage(Colors.red, MdiIcons.closeCircle, mensagem);
  }

  static Widget renderLoading() {
    return Center(child: CircularProgressIndicator());
  }

  static Widget renderLoadingMessage(Color cor, String mensagem) {
    return Container(
      decoration: new BoxDecoration(color: cor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[ 
          Center(child: Column(children: <Widget>[
            renderLoading(),
            SizedBox(height: 25),
            Text(mensagem)
          ]))
        ],
      ),
    );
  }

  static Widget renderNoItemList() {
    return Center(child: Text('Nenhum item disponível'));
  }


}