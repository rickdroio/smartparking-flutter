import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class ConfirmationDialog {

  static Future<bool> dialogYesNo(BuildContext context, String msg) async {
    bool result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text("Alert Dialog title"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                child: new Text("Não"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),

              FlatButton(
                child: new Text("Sim"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),

            ],
          );
        },
      ); 

    return result == null ? false : result;  
  }  

  static Future<int> dialogInputInt(BuildContext context, String msg, String decoration) async {

    TextEditingController _resultController = TextEditingController();

    int result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(msg),
            content: TextFormField(
              controller: _resultController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: decoration),
            ),
            actions: <Widget>[

              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(_resultController.text.isEmpty ? 0 : int.parse(_resultController.text));
                },
              ),

            ],
          );
        },
      ); 

    return result == null ? 0 : result;     
  }

  static Future<double> dialogInputDouble(BuildContext context, String msg, String decoration) async {

    TextEditingController _resultController = TextEditingController();

    double result = await showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(msg),
            content: TextFormField(
              controller: _resultController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: decoration),
            ),
            actions: <Widget>[

              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(_resultController.text.isEmpty ? 0.0 : int.parse(_resultController.text));
                },
              ),

            ],
          );
        },
      ); 

    return result == null ? 0 : result;     
  }  

  static Future<void> dialogShowMessage(BuildContext context, String msg) async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(msg),
            content: Text(msg),
            actions: <Widget>[

              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        },
      ); 
  } 

  static void snackbar({BuildContext context, String titulo, String mensagem, Color cor = Colors.black, bool isDismissible = false, int duration = 5}) {
    Flushbar(
      duration: Duration(seconds: duration),
      title: titulo,
      message: mensagem,
      //icon: Icon(FontAwesomeIcons.exclamationCircle, size: 28.0, color: Colors.blue[300]),
      icon: Icon(Icons.warning),      
      backgroundColor: cor,
    ).show(context);

    //final snackBar = SnackBar(content: Text(mensagem), backgroundColor: cor,);
    //Scaffold.of(context).showSnackBar(snackBar);
  }  

  static void snackbarCloseable({BuildContext context, String mensagem, Color cor = Colors.black}) {
    final snackBar = SnackBar(content: Text(mensagem), backgroundColor: cor, duration: Duration(seconds: 10), 
      action: SnackBarAction(
        label: 'Fechar',
        onPressed: () => Scaffold.of(context).removeCurrentSnackBar(),
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static Future<bool> dialogDelete(BuildContext context) {
    return dialogYesNo(context, 'Confirma exclusão?');
  }

}