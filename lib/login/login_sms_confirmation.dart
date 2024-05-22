import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import 'bloc/login_event.dart';
import 'bloc/login_state.dart';
import 'bloc/login_bloc.dart';

import '../model/login_model.dart';

import '../service/assinatura_service.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/result_render.dart';

import './login_new_page.dart';

import '../service/token_service.dart';

class LoginSmsConfirmationPage extends StatefulWidget {
  final VoidCallback onLogin;
  final String telefone;
  final String verificationId;
  LoginSmsConfirmationPage(this.telefone, this.verificationId, this.onLogin);

  @override
  _LoginSmsConfirmationPageState createState() => _LoginSmsConfirmationPageState();
}

class _LoginSmsConfirmationPageState extends State<LoginSmsConfirmationPage> {

  final LoginBloc bloc = LoginBloc();
  PinEditingController _pinEditingController =  PinEditingController(pinLength: 6, autoDispose: false);

  @override
  void initState() {
    AssinaturaService.setAssinaturaProperty(null); //zerar property toda vez q logar com um novo
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    _pinEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      floatingActionButton: _floatActionButton(),
      appBar: AppBar(
        title: Text(APP_TITLE),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return BlocListener<LoginBloc, LoginState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
          _pinEditingController.clear();
        }
        /*
        else if (state is StateSuccessConfirmation) {
          if (state.loginStatus == LoginStatus.USER_NEW)
            ConfirmationDialog.snackbar(context: context, mensagem: 'Código de verificação validado com sucesso!', cor: Colors.green);
          else if (state.loginStatus == LoginStatus.USER_REGISTERED)
            ConfirmationDialog.snackbar(context: context, mensagem: 'Login efetuado com sucesso!', cor: Colors.green);
        } */
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: bloc,
        builder: (BuildContext context, LoginState state) {
          Widget bodyWidget = _renderInitial();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }

          else if (state is StateSuccessConfirmation) {

            if (state.loginStatus == LoginStatus.USER_NEW) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginNewPage(state.uid, widget.telefone, widget.onLogin)));
              });
            } 
            else if (state.loginStatus == LoginStatus.USER_REGISTERED) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onLogin();
                Navigator.pop(context);
              });
            }
            else if (state.loginStatus == LoginStatus.USER_INVITED) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ConfirmationDialog.dialogShowMessage(context, 'Bem-vindo ${state.convite.nome}, você foi convidado para ser membro de um estacionamento.').then((_) {
                  widget.onLogin();
                  Navigator.pop(context);
                });  
              });
            }      
          }         

          return bodyWidget;
        }  
      )
    );
  }  

  Widget _renderInitial() {
    return ListView(children: <Widget>[
      Container(
        padding: EdgeInsets.all(16),
        child: Column(children: <Widget>[
          Text('Digite o código de 6 digitos enviado para ${widget.telefone}', style: TextStyle(fontSize: 18),),

          PinInputTextField(
            pinLength: 6,
            autoFocus: true,
            pinEditingController: _pinEditingController,
            decoration: UnderlineDecoration(enteredColor: Colors.deepOrange, textStyle: TextStyle(color: Colors.black, fontSize: 24,)),
            onSubmit: _onSubmit,
          ),

          Container(
            padding: EdgeInsets.only(top: 50),
            child: RaisedButton(              
              child: Text('REENVIAR CÓDIGO AGORA', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          )

        ],)
      )    
    ],
   
    );
  }

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      label: Text('Continuar'),
      icon: Icon(Icons.forward),
      onPressed: () {
        if (_pinEditingController.text.length == 6)
          bloc.dispatch(UserPhoneConfirmation(widget.telefone, widget.verificationId, _pinEditingController.text));
      },
    );
  }  

  void _onSubmit(String pin) {
    if (pin.length == 6)
      bloc.dispatch(UserPhoneConfirmation(widget.telefone, widget.verificationId, _pinEditingController.text));
  }

}