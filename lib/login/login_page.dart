import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bloc/login_event.dart';
import 'bloc/login_state.dart';
import 'bloc/login_bloc.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/result_render.dart';

import '../pages/privacy_page.dart';
import './login_sms_confirmation.dart';

import '../service/token_service.dart';

class LoginPage extends StatefulWidget {

  final VoidCallback onLogin;
  LoginPage(this.onLogin) {
    print('called LoginPage');
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final LoginBloc bloc = LoginBloc();
  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(            
      floatingActionButton: _floatActionButton(),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            //decoration: BoxDecoration(color: Colors.lightBlue[200]),
            child: _buildBody(),
          )
        ],
      )
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    _phone.dispose();
    super.dispose();
  }    

  Widget _buildBody() {
    return BlocListener<LoginBloc, LoginState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }    
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: bloc,
        builder: (BuildContext context, LoginState state) {
          Widget bodyWidget = _renderInitial();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }

          return bodyWidget;       
        }  
      )
    );
  }  

  Widget _renderInitial() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _telefoneInput(),
              //_privacy()
            ],
        ),
      );    
  }

  Widget _showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 0.0),
        child: Column(children: <Widget>[
          Image.asset('images/appicon.png', width: 150),
          Image.asset('images/microparking.png', height: 30,),
          Center(child: Text(APP_SUBTITLE, textAlign: TextAlign.center))
          
        ],)
      ),
    );
  }  

  Widget _telefoneInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(   
        //style: TextStyle(color: Colors.white),     
        controller: _phone,
        maxLength: 11,
        maxLines: 1,
        keyboardType: TextInputType.phone,
        autofocus: false,
        decoration: InputDecoration(
          //hintStyle: TextStyle(color: Colors.white),
          labelText: 'Insira seu no. de celular',
          hintText: '(11) 96123-4567',
          icon: Icon(Icons.phone_android)
        ),
      ),
    );
  }  

  Widget _privacy() {
    return FlatButton(
      child: Text(
        'Política de Privacidade',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPage()));
      },
    );
  }

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      label: Text('Continuar'),
      icon: Icon(Icons.forward),
      onPressed: () {
        bloc.dispatch(UserPhoneLogin(_phone.text, _codeSent, _verificationFailed));
      },
    );
  }

  Future _codeSent(String verificationId, [int forceResendingToken]) async {
    //bloc.dispatch(InitialEvent());
    print("called codeSent $verificationId");
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSmsConfirmationPage(_phone.text, verificationId, widget.onLogin)));
      bloc.dispatch(InitialEvent());
    });
  }  

  void _verificationFailed(AuthException authException) {
    print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    bloc.dispatch(LoginError('Erro ao enviar a mensagem de confirmação'));
  }  

   
}