import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:rxdart/rxdart.dart';

import '../model/entrada_model.dart';
import 'saida_page.dart';
import 'bloc/saida_bloc.dart';
import 'bloc/saida_event.dart';
import 'bloc/saida_state.dart';

import '../widgets/result_render.dart';

class SaidaListaPage extends StatefulWidget {

  @override
  _SaidaListaPageState createState() => _SaidaListaPageState();
}

class _SaidaListaPageState extends State<SaidaListaPage> {

  final SaidaBloc bloc = SaidaBloc();
  final searchOnChange = new BehaviorSubject<String>();

  bool activeSearch = false;
  List<Entrada> _entradasAbertas;

  @override
  void initState() {
    bloc.dispatch(SearchEntradasAberto('')); //carga inicial

    searchOnChange
    .debounce((_) => TimerStream(true, const Duration(seconds: 1)))
    .listen((queryString){
      bloc.dispatch(SearchEntradasAberto(queryString));
    });    

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildBody(),
    );
  } 

  PreferredSizeWidget _appBar() {
    if (activeSearch) {
      return AppBar(
        leading: Icon(Icons.search),
        title: TextField(
          onChanged: _search,
          decoration: InputDecoration(
            hintText: "Digite a placa",
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              bloc.dispatch(SearchEntradasAberto(''));
              setState(() => activeSearch = false);
            },
          )
        ],
      );
    } else {
      return AppBar(
        title: Text("Lista Pátio"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => setState(() => activeSearch = true),
          ),
        ],
      );
    }
  }   

  Widget _buildBody() {
    return BlocBuilder<SaidaBloc, SaidaState>(
      bloc: bloc,
      builder: (BuildContext context, SaidaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateSearchEntradasAberto) {
            _entradasAbertas = state.entradas;
            bloc.dispatch(InitialEvent());
        }

        return bodyWidget;       
      }  
    );
  }

  void _search(String queryString) {
    //bloc.dispatch(SearchEntradasAberto(queryString));
    searchOnChange.add(queryString);
  }   

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();

    if (_entradasAbertas != null)
      _entradasAbertas.forEach((doc) {
        lista.add(_detail(doc));      
      }); 

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Entrada entrada) {
    return ListTile(
      leading: Icon(MdiIcons.carSide),  //Chip(avatar: Icon(Icons.local_activity), label: Text(entrada.getCodEntrada(),)),
      title: Text(entrada.placa, style: TextStyle(fontSize: 20)),
      subtitle: Text(entrada.getdataLocal()),
      trailing: entrada.isMensalista ? Text('MENSALISTA') : Text(''),
      onTap: () {
        _callSaidaPage(entrada.id);
      },
    );
  }

  void _callSaidaPage(String entradaId) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SaidaPage(entradaId)));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(SearchEntradasAberto(''));
    }
  }

}