import 'package:flutter/material.dart';
import '../model/usuario_model.dart';
import '../model/assinatura_model.dart';
import '../service/assinatura_service.dart';

class UsuarioEditDialog extends StatefulWidget {  
  final Usuario usuario;
  UsuarioEditDialog(this.usuario);

  @override
  _UsuarioEditDialogState createState() => _UsuarioEditDialogState();
}

class _UsuarioEditDialogState extends State<UsuarioEditDialog> {

  bool _usuarioIsOwner = false;

  @override
  void initState() {
    _checkUuarioOwner();
    super.initState();
  }

  Future _checkUuarioOwner() async {
    Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();
    setState(() {
      _usuarioIsOwner = assinatura.owner == widget.usuario.id; 
      print('isOwner = ${_usuarioIsOwner.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      //title: Text('Convite membro'),
      children: <Widget>[
        _renderInitial(context),
      ],
    );
  }

  Widget _renderInitial(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      ListTile(
        leading: widget.usuario.getUserAvatar(),
        title: Text(widget.usuario.nome),
      ),
      
      Divider(),

      RadioListTile<bool>(
        title: Text('Administrador'),
        subtitle: Text('Os administradores podem gerenciar membros e preferências, além dos privilégios dos demais membros'),
        value: true,
        groupValue: widget.usuario.admin,
        onChanged: !_usuarioIsOwner ? (bool value) { setState( () =>widget.usuario.admin = value); } : null
      ),   

      RadioListTile<bool>(
        title: Text('Normal'),
        subtitle: Text('Os membros normais podem apenas dar entrada e saída'),
        value: false,
        groupValue: widget.usuario.admin,
        onChanged: !_usuarioIsOwner ? (bool value) { setState( () =>widget.usuario.admin = value); } : null
      ), 

      Divider(),

      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        FlatButton(
          child: Text('SALVAR'), 
          onPressed: !_usuarioIsOwner ? () {Navigator.pop(context, widget.usuario.admin);} : null
        )
      ],)         
   

    ],);
  }  

}