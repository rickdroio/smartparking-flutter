import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/caixa_event.dart';
import 'bloc/caixa_state.dart';
import 'bloc/caixa_bloc.dart';
import '../model/entrada_model.dart';

import '../widgets/result_render.dart';

class CaixaListaDetailsPage extends StatefulWidget {
  final String id;
  CaixaListaDetailsPage(this.id);

  @override
  _CaixaListaPageState createState() => _CaixaListaPageState();
}

class _CaixaListaPageState extends State<CaixaListaDetailsPage> {

  final CaixaBloc bloc = CaixaBloc();
  List<Entrada> _entradas;

  @override
  void initState() {
    bloc.dispatch(GetCaixaDetalhes(widget.id)); //carga inicial
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildBody(),
    );
  }
  Widget _appBar() {
    return AppBar(
      title: Text("Lista Caixa"),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<CaixaBloc, CaixaState>(
      bloc: bloc,
      builder: (BuildContext context, CaixaState state) {
        Widget bodyWidget = ResultRender.renderLoading();

        if (state is StateGetCaixaDetalhes) {
          _entradas = state.entradas;
          //bloc.dispatch(InitialEvent());
          bodyWidget = _renderInitial();
        }

        return bodyWidget;    
      }
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();

    if (_entradas != null)
      _entradas.forEach((doc) {
        lista.add(_detail(doc));      
      });

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }  

  Widget _detail(Entrada entrada) {
    return ListTile(
      leading: Icon(MdiIcons.car),
      title: Text(entrada.placa),
      subtitle: Text(entrada.modelo),
      trailing: Text(entrada.isMensalista ? 'MENSALISTA' : entrada.getvalorTotal()),
    );
  }  
 
}