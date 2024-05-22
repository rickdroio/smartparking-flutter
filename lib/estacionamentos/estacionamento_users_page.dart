import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/estacionamento_bloc.dart';
import 'bloc/estacionamento_event.dart';
import 'bloc/estacionamento_state.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/estacionamento.dart';
import '../model/usuario_model.dart';

class EstacionamentoUsersPage extends StatefulWidget {
  final String estacionamentoId;
  EstacionamentoUsersPage(this.estacionamentoId);
  @override
  _EstacionamentoUsersPageState createState() => _EstacionamentoUsersPageState();
}

class _EstacionamentoUsersPageState extends State<EstacionamentoUsersPage> {
  final EstacionamentoBloc bloc = EstacionamentoBloc();
  
  List<Usuario> _usuarios;
  Estacionamento _estacionamento;

  @override
  void initState() {    
    bloc.dispatch(LoadInitialUsersData(widget.estacionamentoId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membros Estacionamento'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<EstacionamentoBloc, EstacionamentoState>(
      bloc: bloc,
      builder: (BuildContext context, EstacionamentoState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) { ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);});          
          bloc.dispatch(InitialEvent());
        }           
        else if (state is StateSuccess) {
          Future.delayed(Duration(seconds: 1), () => Navigator.pop(context, true));
        }        
        else if (state is StateInitialUserData) {
          _usuarios = state.usuarios;
          _estacionamento = state.estacionamento;
          bloc.dispatch(InitialEvent());
        } 

        return bodyWidget;
      }  
    );
  }

  Widget _renderInitial() {
    List<Widget> items = List<Widget>();

    if (_usuarios != null && _usuarios.length>0) {
      _usuarios.forEach((usuario) {
        items.add(
          SwitchListTile(
            title: Text(usuario.nome),
            value: _estacionamento.usuarios.contains(usuario.id),
            onChanged: (bool value) { 
              if (value) _estacionamento.usuarios.add(usuario.id);
              else _estacionamento.usuarios.remove(usuario.id);
              setState((){}); 
            },
            secondary: usuario.getUserAvatar(),
          ) 
        );
      });
    }

    return ListView(children:items);
   } 

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.save),
      label: Text('Salvar'),
      onPressed: _salvarForm,
    );
  }  

  _salvarForm() {
    bloc.dispatch(SaveUsersData(_estacionamento.id, _usuarios));
  }     

}