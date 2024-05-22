import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

import 'bloc/tabela_bloc.dart';
import 'bloc/tabela_event.dart';
import 'bloc/tabela_state.dart';

import '../model/tabela_model.dart';
import '../model/tabela_item_model.dart';
import 'tabela_edit_item_page.dart';
import '../widgets/confirmation_dialog.dart';
import '../service/tabela_service.dart';

import '../widgets/result_render.dart';

class TabelaItemListaPage extends StatefulWidget {
  final Tabela tabela;
  TabelaItemListaPage(this.tabela);  
  @override
  _TabelaItemListaPageState createState() => _TabelaItemListaPageState();
}

class _TabelaItemListaPageState extends State<TabelaItemListaPage> {
  final TabelaBloc bloc = TabelaBloc();  
  List<TabelaItem> _tabelaItems;

  @override
  void initState() {
    bloc.dispatch(SearchTabelaItems(widget.tabela.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tabela.nomeTabela),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(MdiIcons.playNetwork, color: Colors.white,), 
            label: Text('Simular', style: TextStyle(color: Colors.white)), 
            onPressed: _onSimular,)
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _floatingSpeedDial(),
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
        else if (state is StateSearchTabelaItems) {
          _tabelaItems = state.items;
          bloc.dispatch(InitialEvent());
        }

        return bodyWidget;       
      }  
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();
    if (_tabelaItems != null)
      _tabelaItems.forEach((doc) {
        lista.add(_detail(doc));      
      });    

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(TabelaItem item) {
    return Container(
      child: Column(children: <Widget>[
        ListTile(
          leading: Icon(MdiIcons.avTimer),
          title: Text(item.getDescricao()),
          subtitle: Text(item.getPreco()),
          onTap: () {
            _callEditPage(tabelaId: item.tabelaId, tipo: item.tipo, id: item.id);
          },
          /*
          trailing: FlatButton(
            child: Icon(Icons.delete),
            onPressed: () {
              ConfirmationDialog.dialogDelete(context).then((confirm) {
                if (confirm) {
                  TabelaService.deleteItemTabela(item);
                  bloc.dispatch(SearchTabelaItems(widget.tabela.id));
                }
              });
            },

          ) */
                        
        ),
      ],) 
    );
  } 

  Widget _floatingSpeedDial(){
    return SpeedDial(
      animatedIcon: AnimatedIcons.view_list,
      children: [
        SpeedDialChild(
          child: Icon(MdiIcons.coin),
          backgroundColor: Colors.green,
          label: 'Preço "Até X minutos"',
          onTap: () {
            _callEditPage(tabelaId: widget.tabela.id, tipo: 1);
          } 
        ),
        SpeedDialChild(
          child: Icon(MdiIcons.coin),
          backgroundColor: Colors.blue,
          label: 'Preço "A cada X minutos"',
          onTap: () {
            _callEditPage(tabelaId: widget.tabela.id, tipo: 2);
          } 
        ),
        SpeedDialChild(
          child: Icon(MdiIcons.coin),
          backgroundColor: Colors.purple,
          label: 'Preço Fixo',
          onTap: () {
            _callEditPage(tabelaId: widget.tabela.id, tipo: 3);
          } 
        ), 
      ],
    );
  }

  void _onSimular() async {
    int tempo = await ConfirmationDialog.dialogInputInt(context, 'Simulação tabela preço', 'Tempo em minutos');
    if (tempo>0) {
      double preco = await TabelaService.calcularPrecoSaida(widget.tabela.id, tempo);
      String precoStr = NumberFormat.currency(decimalDigits: 2, locale: 'pt_br', symbol: 'R\$').format(preco);

      ConfirmationDialog.dialogShowMessage(context, 'Preço para ${tempo.toString()} min = $precoStr');
    }
  }  

  void _callEditPage({String tabelaId, String id, int tipo}) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TabelaEditItemPage(tabelaId: tabelaId, tipo: tipo, itemId: id)));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(SearchTabelaItems(widget.tabela.id));
    }
  }    

}