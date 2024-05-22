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
  final double _appBarHeight = 256.0;
  List<Tabela> _tabelas;

  @override
  void initState() {
    bloc.dispatch(SearchTabelas());
    super.initState();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Tabela'),
                background: Stack(
                  fit: StackFit.expand, children: <Widget>[
                    Image.asset('images/parking.jpg', fit: BoxFit.cover, height: _appBarHeight),
                    DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment(0.0, -1.0), 
                      end: Alignment(0.0, -0.4), 
                      colors: <Color>[Color(0x60000000), Color(0x00000000)],
                    )))
                  ],
                ) 
              ),
            ),

            SliverList(delegate: SliverChildListDelegate([
              _buildBody()
            ]))
          ],          
        ),
        
        floatingActionButton: _floatingActionButton()
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
      return Column(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Tabela tabela) {
    return Container(
      child: Column(children: <Widget>[
        ListTile(
          leading: Icon(Icons.folder_open),
          title: Text(tabela.getNomeTabela()),
          subtitle: Text(tabela.getTabelaAtivaStr()),                    
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TabelaItemListaPage(tabela)));
          },
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(child: Icon(MdiIcons.folderEdit), onPressed: () { 
              _callEditPage(tabela);
            },),
            FlatButton(child: Icon(MdiIcons.folderRemove), onPressed: () { },)
          ],
        ),
        
        Divider()
      ],) 
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(child: Icon(MdiIcons.folderPlus), 
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