import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/mensalista_bloc.dart';
import 'bloc/mensalista_event.dart';
import 'bloc/mensalista_state.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/mensalista_model.dart';

class MensalistaEditPage extends StatefulWidget {
  final String id;
  MensalistaEditPage(this.id);
  @override
  _MensalistaEditPageState createState() => _MensalistaEditPageState();
}

class _MensalistaEditPageState extends State<MensalistaEditPage> {
  final MensalistaBloc bloc = MensalistaBloc();
  
  Mensalista _mensalista;
  final _nome = TextEditingController();
  final _placa = TextEditingController();
  final _modelo = TextEditingController();

  @override
  void initState() {    
    if (widget.id !=null)
      bloc.dispatch(LoadInitialItemData(widget.id));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Mensalista'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocListener<MensalistaBloc, MensalistaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }    
      },
      child: BlocBuilder<MensalistaBloc, MensalistaState>(
        bloc: bloc,
        builder: (BuildContext context, MensalistaState state) {
          Widget bodyWidget = _renderInitial(false);

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }
          else if (state is StateSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context, true));
          }       
          else if (state is StateModeloLoading) {
            bodyWidget = _renderInitial(true);
          }   
          else if (state is StateModeloSuccess) {
            _modelo.text = state.sinesp.modelo;
            //bloc.dispatch(InitialEvent());
          }   
          else if (state is StateInitialItemData) {
            _mensalista = state.mensalista;
            if (_mensalista != null && _mensalista.id != null) {
              _nome.text = _mensalista.nome;
              _placa.text = _mensalista.placa;
              _modelo.text = _mensalista.modelo;
              //bloc.dispatch(InitialEvent());
            }
          }                               

          return bodyWidget;       
        }  
      )
    );
  }    

  /*
  Widget _buildBody() {
    return BlocBuilder<MensalistaBloc, MensalistaState>(
      bloc: bloc,
      builder: (BuildContext context, MensalistaState state) {
        Widget bodyWidget = _renderInitial(false);

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
        else if (state is StateModeloLoading) {
          bodyWidget = _renderInitial(true);
        }        
        else if (state is StateModeloSuccess) {
          _modelo.text = state.sinesp.modelo;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateInitialItemData) {
          _mensalista = state.mensalista;
          if (_mensalista != null && _mensalista.id != null) {
            _nome.text = _mensalista.nome;
            _placa.text = _mensalista.placa;
            _modelo.text = _mensalista.modelo;
            bloc.dispatch(InitialEvent());
          }
        }        

        return bodyWidget;       
      }  
    );
  }
  */

  Widget _renderInitial(bool loadingModel) {
    return ListView(children: <Widget>[

      ListTile(
        leading: Icon(Icons.place),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Nome do mensalista'),
          controller: _nome,    
          textCapitalization: TextCapitalization.words,
        ),
      ),      

      ListTile(
        leading: Icon(Icons.arrow_forward),
        title: Column(children: <Widget>[
          TextFormField(
            maxLength: 7,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: 'Placa'),
            controller: _placa,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))]
          ),
        ],)
      ), 

      ListTile(
        leading: Icon(MdiIcons.car),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Modelo'),
          controller: _modelo,    
          textCapitalization: TextCapitalization.words,
        ),
        trailing: GestureDetector(
          child: loadingModel ? CircularProgressIndicator() : Icon(MdiIcons.refresh),
          onTap: () => bloc.dispatch(SearchPlaca(_placa.text)),
        )
      ),       

    ]);
  } 

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.save),
      label: Text('Salvar'),
      onPressed: _salvarForm,
    );
  }  

  _salvarForm() {
    if (_mensalista == null) _mensalista = Mensalista();
    _mensalista.nome = _nome.text;
    _mensalista.placa = _placa.text;
    _mensalista.modelo = _modelo.text;

    bloc.dispatch(SaveMensalista(_mensalista));
  }     

}