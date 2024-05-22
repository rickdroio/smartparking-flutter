import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/estacionamento_bloc.dart';
import 'bloc/estacionamento_event.dart';
import 'bloc/estacionamento_state.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/estacionamento.dart';

class EstacionamentoEditPage extends StatefulWidget {
  final String estacionamentoId;
  EstacionamentoEditPage(this.estacionamentoId);
  @override
  _EstacionamentoEditPageState createState() => _EstacionamentoEditPageState();
}

class _EstacionamentoEditPageState extends State<EstacionamentoEditPage> {
  final EstacionamentoBloc bloc = EstacionamentoBloc();
  
  Estacionamento _estacionamento;
  final _nome = TextEditingController();
  final _endereco = TextEditingController();
  final _capacidade = TextEditingController();
  bool _estacionamentoAtivo = true;

  @override
  void initState() {    
    if (widget.estacionamentoId !=null)
      bloc.dispatch(LoadInitialItemData(widget.estacionamentoId));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estacionamento'),
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
        else if (state is StateInitialItemData) {
          _estacionamento = state.estacionamento;
          if (_estacionamento != null && _estacionamento.id != null) {
            _nome.text = _estacionamento.nome;
            _endereco.text = _estacionamento.endereco;
            _capacidade.text = _estacionamento.capacidade.toString();
            _estacionamentoAtivo = _estacionamento.ativo ?? false;
            bloc.dispatch(InitialEvent());
          }
        }        

        return bodyWidget;       
      }  
    );
  }

  Widget _renderInitial() {
    return ListView(children: <Widget>[

      ListTile(
        leading: Icon(Icons.place),
        title: TextFormField(
          decoration: InputDecoration(labelText: 'Nome do estacionamento'),
          controller: _nome,    
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
        leading: Icon(MdiIcons.carMultiple),
        title: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Capacidade estacionamento'),
          controller: _capacidade,
        ),
        subtitle: Text('Deixe vazio para não controlar a capacidade máxima'),
      ),

      SwitchListTile(
        title: Text('Ativo'),
        value: _estacionamentoAtivo,
        onChanged: (bool value) { setState(() { _estacionamentoAtivo = value; }); },
        secondary: Icon(MdiIcons.checkDecagram),
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
    if (_estacionamento == null) _estacionamento = Estacionamento();
    _estacionamento.nome = _nome.text;
    _estacionamento.endereco = _endereco.text;
    _estacionamento.capacidade = _capacidade.text.isNotEmpty ? int.parse(_capacidade.text) : 0;
    _estacionamento.ativo = _estacionamentoAtivo;
    bloc.dispatch(SaveEstacionamento(_estacionamento));
  }     

}