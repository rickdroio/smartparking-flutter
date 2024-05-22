import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/result_render.dart';

import 'bloc/caixa_event.dart';
import 'bloc/caixa_state.dart';
import 'bloc/caixa_bloc.dart';

import '../model/caixa_item_model.dart';
import '../model/caixa_model.dart';
import '../model/entrada_model.dart';

class CaixaConsultaPage extends StatefulWidget {

  @override
  _CaixaConsultaState createState() => _CaixaConsultaState();
}

class _CaixaConsultaState extends State<CaixaConsultaPage> {

  final CaixaBloc bloc = CaixaBloc();
  Caixa _caixa;
  List<CaixaItem> itemsCaixa; 
  List<Entrada> entradas;

  @override
  void initState() {
    bloc.dispatch(GetCaixaAbertoEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta Caixa'),
      ),
      body: _buildBody(),      
    );  
  }

  Widget _buildBody() {
    return BlocBuilder<CaixaBloc, CaixaState>(
      bloc: bloc,
      builder: (BuildContext context, CaixaState state) {
        Widget bodyWidget = ResultRender.renderLoading();

        if (state is StateGetCaixaAberto) {
          _caixa = state.caixa;
          itemsCaixa = state.itemsCaixa;
          entradas = state.entradas;
          //bloc.dispatch(InitialEvent());
          bodyWidget = _renderInitial();
        }

        return bodyWidget;
      }
    );
  } 
  
  Widget _renderInitial() {
    return ListView(children: <Widget>[
      Card(margin: EdgeInsets.all(5), child: Column(children: <Widget>[
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(MdiIcons.fileFind)) ,
          title: Text('Valor em caixa', style: TextStyle(fontWeight: FontWeight.bold),),
          //trailing: Text(_caixa.id),
        ),
        Container(
          margin: EdgeInsets.all(5),
          child: Text(_caixa.getvalorTotal(), style: TextStyle(fontSize: 30))
        ),
        _showItems(),
      ])),

      ... _renderEntradas()
    ],); 
  }

  Widget _showItems() {
    List<Widget> items = List<Widget>();
    itemsCaixa.forEach((itemCaixa) {
      items.add(
        ListTile(
          leading: Icon(MdiIcons.coin),
          title: Text(itemCaixa.formaPgto),
          subtitle: Text(itemCaixa.getvalorTotal()),
        ),           
      );
    });

    return Column(children: items);
  } 

  List<Widget> _renderEntradas() {
    List<Widget> listaEntradas = List<Widget>();

    entradas.forEach((entrada) {
      listaEntradas.add(
        ListTile(
          leading: Icon(MdiIcons.car),
          title: Text(entrada.placa),
          subtitle: Text(entrada.modelo),
          trailing: Text(entrada.isMensalista ? 'MENSALISTA' : entrada.getvalorTotal()),
        )
      );
    });

    return listaEntradas;
  } 

}