import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/usuario_bloc.dart';
import 'bloc/usuario_event.dart';
import 'bloc/usuario_state.dart';

import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/estacionamento.dart';

class UsuarioConvitePage extends StatefulWidget {
  @override
  _UsuarioConvitePageState createState() => _UsuarioConvitePageState();
}

class _UsuarioConvitePageState extends State<UsuarioConvitePage> {
  final UsuarioBloc bloc = UsuarioBloc();
  
  final _nome = TextEditingController(); 
  final _phone = TextEditingController(); 
  List<Estacionamento> _estacionamentos;
  String _estacionamentoId = '';

  @override
  void initState() {
    bloc.dispatch(LoadConviteUser());
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convite Membros'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<UsuarioBloc, UsuarioState>(
      bloc: bloc,
      builder: (BuildContext context, UsuarioState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) { ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);});          
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateInitialDataConvite) {
          _estacionamentos = state.estacionamento;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateSuccess) {
          bodyWidget = ResultRender.renderSuccess('Convite efetuado com sucesso!');
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context, true); 
          });
        }           
        return bodyWidget;
      }  
    );
  }

  Widget _renderInitial() {
    return ListView(children: <Widget>[

      ListTile(
        leading: const Icon(Icons.supervised_user_circle),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Nome'),
          controller: _nome,    
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
        ),
      ),      

      ListTile(
        leading: const Icon(Icons.phone_android),
        title: TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: new InputDecoration(
              labelText: 'Insira o celular do novo membro',
              hintText: '(11) 96123-4567',
              //icon: new Icon(Icons.phone_android)
          ),
        ),
      ), 

      ... _renderEstacionamentos(),     
       
    ]);
  }

  List<Widget> _renderEstacionamentos() {
    List<Widget> items = List<Widget>();  

    items.add(
      ListTile(
        leading: const Icon(Icons.place),
        title: Text('Selecione um estacionamento:')
      )
    );

    if (_estacionamentos != null) {
      _estacionamentos.forEach((e) {
        items.add(
          RadioListTile<String>(          
            title: Text(e.nome),
            value: e.id,
            groupValue: _estacionamentoId,
            onChanged: (String value) { 
              setState( () => _estacionamentoId = value); 
            },
          ) 
        );
      });
    }

    return items;
  }

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.save),
      label: Text('Salvar'),
      onPressed: _salvarForm,
    );
  }  

  _salvarForm() async {
    bloc.dispatch(ConviteUser(_nome.text, _phone.text, _estacionamentoId));
  }     

}