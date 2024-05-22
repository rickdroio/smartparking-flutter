import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'caixa_page.dart';

import 'bloc/caixa_event.dart';
import 'bloc/caixa_state.dart';
import 'bloc/caixa_bloc.dart';
import '../model/caixa_model.dart';

import '../widgets/result_render.dart';

import './caixa_lista_details_page.dart';

class CaixaListaPage extends StatefulWidget {

  @override
  _CaixaListaPageState createState() => _CaixaListaPageState();
}

class _CaixaListaPageState extends State<CaixaListaPage> {

  final CaixaBloc bloc = CaixaBloc();
  List<Caixa> caixasFechados;

  @override
  void initState() {
    bloc.dispatch(GetCaixasFechado()); //carga inicial
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      floatingActionButton: floatActionButton(),
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

        if (state is StateGetCaixasFechado) {
          caixasFechados = state.caixas;
          //bloc.dispatch(InitialEvent());
          bodyWidget = _renderInitial();
        }

        return bodyWidget;    
      }
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();

    if (caixasFechados != null)
      caixasFechados.forEach((doc) {
        lista.add(_detail(doc));      
      });    

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }  

  Widget _detail(Caixa caixa) {
    return ListTile(
      leading: Icon(MdiIcons.cashRegister),
      title: Text('Caixa'),
      subtitle: Text(caixa.getdataFechamento()),
      trailing: Text(caixa.getvalorTotal()),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CaixaListaDetailsPage(caixa.id))),
    );
  }  

  Widget floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.check),
      label: Text('Fechar'),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CaixaPage()));
      },
    );
  }

}