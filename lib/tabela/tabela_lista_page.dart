import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'tabela_edit_page.dart';
import 'tabela_item_lista_page.dart';

import 'bloc/tabela_bloc.dart';
import 'bloc/tabela_event.dart';
import 'bloc/tabela_state.dart';

import '../model/tabela_model.dart';
import '../widgets/result_render.dart';

class TabelaListaPage extends StatefulWidget {
  @override
  _TabelaListaPageState createState() => _TabelaListaPageState();
}

class _TabelaListaPageState extends State<TabelaListaPage> {
  final TabelaBloc bloc = TabelaBloc();
  List<Tabela> _tabelas;
  String _tabelaPadrao;

  @override
  void initState() {
    bloc.dispatch(SearchTabelas());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabelas de preço'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TabelaBloc, TabelaState>(
      bloc: bloc,
      builder: (BuildContext context, TabelaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateSearchTabelas) {
          _tabelas = state.tabelas;
          bloc.dispatch(InitialEvent());
        }

        return bodyWidget;       
      }  
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();
    if (_tabelas != null)
      _tabelas.forEach((doc) {
        lista.add(_detail(doc));      
      }); 

    if (lista.length >0)  
      return ListView(
        children: lista,
      );
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Tabela tabela) {
    return Container(
      key: Key(tabela.id),
      child: Column(children: <Widget>[
        ListTile(
          leading: Icon(Icons.folder_open),
          title: Text(tabela.getNomeTabela()),
          subtitle: tabela.tabelaAtiva ?? false ? Text('Ativo', style: TextStyle(color: Colors.green)) : Text('Desativado', style: TextStyle(color: Colors.red)), 
          
          trailing: FlatButton.icon(
            icon: Icon(MdiIcons.coin),
            label: Text('Editar preços'),
            onPressed: () { 
              Navigator.push(context, MaterialPageRoute(builder: (context) => TabelaItemListaPage(tabela)));
            },
          ),  

          onTap: () {
            _callEditPage(tabela); 
          },
        ),

        /*
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Padrão'),
            Switch(
              value: _tabelaPadrao == tabela.id,
              onChanged: (bool value) {bloc.dispatch(SetTabelaPrecoPadrao(tabela.id));}
            ),
          ],),  
        */      
       
        Divider()
      ],) 
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton.extended(
      label: Text('Nova tabela'),
      icon: Icon(MdiIcons.folderPlus), 
      onPressed: () {
        _callEditPage(null);
      }
    );
  }

  void _callEditPage(Tabela tabela) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TabelaEditPage(tabela == null ? null : tabela.id)));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(SearchTabelas());
    }
  }  

}