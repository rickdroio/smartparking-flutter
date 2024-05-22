import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/tabela_edit_item_bloc.dart';
import 'bloc/tabela_event.dart';
import 'bloc/tabela_state.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import '../model/tabela_item_model.dart';

class TabelaEditItemPage extends StatefulWidget {
  final String tabelaId;
  final String itemId;
  final int tipo;
  TabelaEditItemPage({this.tabelaId, this.itemId, this.tipo});
  @override
  _TabelaEditItemPageState createState() => _TabelaEditItemPageState();
}

class _TabelaEditItemPageState extends State<TabelaEditItemPage> {
  final TabelaEditItemBloc bloc = TabelaEditItemBloc();
  TabelaItem _tabelaItem;
  final _periodo = TextEditingController();
  final _periodoAux = TextEditingController();
  final _preco = TextEditingController(); 

  @override
  void initState() {
    if (widget.itemId != null)
      bloc.dispatch(LoadInitialItemData(widget.tabelaId, widget.itemId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preço'),
        actions: <Widget>[
          if (widget.itemId != null)
            FlatButton(
              child: Icon(MdiIcons.delete, color: Colors.white,), 
              onPressed: () {
                ConfirmationDialog.dialogDelete(context).then((confirm) {
                  if (confirm) {
                    bloc.dispatch(DeleteTabelaItem(_tabelaItem));
                  }
                });
              }
            )
        ],        
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TabelaEditItemBloc, TabelaState>(
      bloc: bloc,
      builder: (BuildContext context, TabelaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) { ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);});          
          bloc.dispatch(InitialEvent());
        }           
        else if (state is StateInitialTabelaItemData) {
          _tabelaItem = state.item;
          if (_tabelaItem.id != null) {
            _periodo.text = _tabelaItem.periodo.toString();
            _preco.text = _tabelaItem.preco.toString();
            _periodoAux.text = _tabelaItem.periodoAux.toString();          
          }
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateSuccess) {
          Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context, true));
        }
        
        return bodyWidget;
      }  
    );
  }

  Widget _renderInitial() {
    Widget renderPeriodo;
    if (widget.tipo == 1){
      renderPeriodo = _renderPeriodoAte();
    }
    else if (widget.tipo == 2){
      renderPeriodo = _renderPeriodoACada();
    }
    else if (widget.tipo == 3){
      renderPeriodo = _renderPeriodoFixo();
    }

    return ListView(children: <Widget>[
      renderPeriodo,
      ListTile(
        leading: const Icon(MdiIcons.coin),
        title: TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Preço'),
          controller: _preco, 
        ),
      ),        
    ]);
  }

  Widget _renderPeriodoAte() {
    return ListTile(
      leading: const Icon(MdiIcons.avTimer, color: Colors.green),
      title: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Até'),
        controller: _periodo,    
      ),
      trailing: Text('minutos'),
    );
  }

  Widget _renderPeriodoACada() {
    return Column(children: <Widget>[
      ListTile(
        leading: const Icon(MdiIcons.avTimer, color: Colors.blue,),
        title: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'A cada'),
          controller: _periodoAux,    
        ),
        trailing: Text('minutos'),
      ),
      ListTile(
        leading: const Icon(MdiIcons.avTimer, color: Colors.blue,),
        title: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'depois de'),
          controller: _periodo,    
        ),
        trailing: Text('minutos'),
      ),      

    ],);
  }  

  Widget _renderPeriodoFixo() {
    return ListTile(
      leading: const Icon(MdiIcons.avTimer, color: Colors.purple,),
      title: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Fixo após'),
        controller: _periodo,
      ),
      trailing: Text('minutos'),
    );
  }   

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.save),
      label: Text('Salvar'),
      onPressed: _salvarForm,
    );
  }  

  _salvarForm() async {
    TabelaItem tabelaItem = TabelaItem();
    tabelaItem.tabelaId = widget.tabelaId;
    tabelaItem.tipo = widget.tipo;
    tabelaItem.periodo = int.parse(_periodo.text);
    tabelaItem.periodoAux = _periodoAux.text.isNotEmpty ? int.parse(_periodoAux.text) : 0;
    tabelaItem.preco = double.parse(_preco.text); 

    bool valueZero = true;
    if (tabelaItem.preco == 0) {
      valueZero = await ConfirmationDialog.dialogYesNo(context, 'Confirma que preço para esse período será igual a zero (cortesia)?');
    }

    if (valueZero) {
      bloc.dispatch(SaveTabelaItem(tabelaItem));
    }
  }     

}