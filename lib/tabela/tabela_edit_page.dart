import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/tabela_edit_bloc.dart';
import 'bloc/tabela_event.dart';
import 'bloc/tabela_state.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/tabela_model.dart';

class TabelaEditPage extends StatefulWidget {
  final String tabelaId;
  TabelaEditPage(this.tabelaId);
  @override
  _TabelaEditPageState createState() => _TabelaEditPageState();
}

class _TabelaEditPageState extends State<TabelaEditPage> {
  final TabelaEditBloc bloc = TabelaEditBloc();
  Tabela _tabela;
  final _nomeTabelaController = TextEditingController();
  final _tolerancia = TextEditingController();
  bool _tabelaAtiva = true;
  bool _tabelaPadrao = true;

  @override
  void initState() {    
    if (widget.tabelaId !=null)
      bloc.dispatch(LoadInitialData(widget.tabelaId));
    else {
      _tolerancia.text = '0'; //valor inicial
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabela Preço'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocListener<TabelaEditBloc, TabelaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }
        else if (state is StateSuccess) {
          //Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context, true));
          Navigator.pop(context, true);
        }        
      },
      child: BlocBuilder<TabelaEditBloc, TabelaState>(
        bloc: bloc,
        builder: (BuildContext context, TabelaState state) {
          Widget bodyWidget = _renderInitial();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }
          else if (state is StateInitialTabelaData) {
            _tabela = state.tabela;
            if (_tabela != null && _tabela.id != null) {
              _tabelaAtiva = state.tabela.tabelaAtiva == null ? false : state.tabela.tabelaAtiva;
              _nomeTabelaController.text = state.tabela.nomeTabela;
              _tolerancia.text = state.tabela.toleranciaPeriodos.toString();    
              //bloc.dispatch(InitialEvent());
            }
          }

          return bodyWidget;       
        }  
      )
    );
  }

  Widget _renderInitial() {
    return ListView(children: <Widget>[

        ListTile(
          leading: const Icon(Icons.folder_open),
          title: TextFormField(
            decoration: InputDecoration(labelText: 'Nome da Tabela'),
            controller: _nomeTabelaController,   
            textCapitalization: TextCapitalization.words, 
          ),
        ),

        ListTile(
          leading: const Icon(MdiIcons.timerOff),
          title: TextFormField(
            decoration: InputDecoration(labelText: 'Tolerancia entre períodos'),
            keyboardType: TextInputType.number,
            controller: _tolerancia,
          ),
          trailing: Text('minutos'),
        ), 

      SwitchListTile(
        title: Text('Tabela Ativa'),
        value: _tabelaAtiva,
        onChanged: (bool value) { setState(() { _tabelaAtiva = value; }); },
        secondary: const Icon(MdiIcons.checkDecagram),
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
    if (_tabela == null) _tabela =Tabela();
    _tabela.nomeTabela = _nomeTabelaController.text;
    _tabela.tabelaAtiva = _tabelaAtiva;
    _tabela.toleranciaPeriodos = int.parse(_tolerancia.text);
    bloc.dispatch(SaveTabela(_tabela));
  }     

}