import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/login_event.dart';
import 'bloc/login_state.dart';
import 'bloc/login_bloc.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/result_render.dart';
import '../model/estacionamento.dart';
import '../model/usuario_model.dart';

class LoginNewPage extends StatefulWidget {
  final String uid;
  final String telefone;
  final VoidCallback onLogin;
  LoginNewPage(this.uid, this.telefone, this.onLogin);

  @override
  _LoginNewPageState createState() => _LoginNewPageState();
}

class _LoginNewPageState extends State<LoginNewPage> {

  final LoginBloc bloc = LoginBloc();

  final _email = TextEditingController();
  final _nome = TextEditingController();
  final _endereco = TextEditingController();
  final _estacionamento = TextEditingController();
  final _capacidade = TextEditingController();

  final _promo = TextEditingController();

  @override
  void dispose() {
    bloc.dispose();
    _email.dispose();
    _nome.dispose();
    _endereco.dispose();
    _estacionamento.dispose();
    _capacidade.dispose();
    _promo.dispose();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldState,
      //floatingActionButton: floatActionButton(),
      appBar: AppBar(
        title: Text('Novo Cadastro'),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LoginBloc, LoginState>(
      bloc: bloc,
      builder: (BuildContext context, LoginState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) { ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);});          
          bloc.dispatch(InitialEvent());
        } 
        else if (state is StateSuccessNewUser) {
          
          bodyWidget = ResultRender.renderLoadingMessage(Colors.green, 'Processando infomarções...');
          Future.delayed(const Duration(seconds: 12), () { //TODO - possivel problema, trigger demorar mais que 10s
            widget.onLogin();
            Navigator.pop(context); 
          });
        }

        return bodyWidget;
      }  
    );
  }

  Widget _renderInitial() {
    return ListView(children: <Widget>[
      ListTile(
        leading: Icon(Icons.supervised_user_circle),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Seu Nome'),
          controller: _nome,    
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
        ),
      ),

      ListTile(
        leading: Icon(MdiIcons.email),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Email'),
          controller: _email,  
          keyboardType: TextInputType.emailAddress  
        ),
      ),      
   
      ListTile(
        leading: Icon(Icons.place),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Nome do estacionamento (fantasia)'),
          controller: _estacionamento,    
          textCapitalization: TextCapitalization.words,
        ),
      ),

      ListTile(
        leading: Icon(MdiIcons.mapSearch),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Endereço estacionamento'),
          controller: _endereco,
          textCapitalization: TextCapitalization.words,
        ),
      ),

      ListTile(
        leading: Icon(MdiIcons.swapHorizontal),
        title: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Capacidade vagas estacionamento'),
          controller: _capacidade,
        ),
        subtitle: Text('Deixe vazio para não controlar a capacidade máxima'),
      ),

      ListTile(
        leading: Icon(MdiIcons.ticket),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Código Promocional'),
          controller: _promo,
          textCapitalization: TextCapitalization.characters,
        ),
      ),

      _btnEntrar()

    ],); 
  }

  Widget _btnEntrar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 45.0, 16, 0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: Text('Registrar'),
          onPressed: onSubmit
          ),
        ),
    );
  }

  void onSubmit() {
    Estacionamento estacionamento = Estacionamento(
      endereco: _endereco.text,
      nome: _estacionamento.text,
      capacidade: int.parse(_capacidade.text.isNotEmpty ? _capacidade.text : 0)
    );

    Usuario usuario = Usuario(
      id: widget.uid,
      admin: true, //no cadastro inicial o usuário é o admin
      nome: _nome.text,
      telefone: widget.telefone,
      email: _email.text,
    );

    bloc.dispatch(UserNew(estacionamento, usuario, _promo.text));
  }


   
}