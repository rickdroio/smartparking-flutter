import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../shared/utils.dart';

import '../model/entrada_model.dart';
import '../model/tabela_model.dart';

import 'bloc/saida_bloc.dart';
import 'bloc/saida_event.dart';
import 'bloc/saida_state.dart';
import '../model/caixa_model.dart';

import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

class SaidaPage extends StatefulWidget {
  final String idEntrada; 
  SaidaPage(this.idEntrada);

  @override
  _SaidaPageState createState() => _SaidaPageState();
}

class _SaidaPageState extends State<SaidaPage> {

  Entrada _entrada;
  List<Tabela> _tabelas;
  Tabela _selectedTabela;
  //bool _selected = false;

  final SaidaBloc bloc = SaidaBloc();

  @override
  void initState() {
    bloc.dispatch(CalcularSaida(widget.idEntrada));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldState,
      //floatingActionButton: floatActionButton(),
      appBar: AppBar(
        title: Text('Saída'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(MdiIcons.check, color: Colors.white,), 
            label: Text('Concluir', style: TextStyle(color: Colors.white)), 
            onPressed: () => bloc.dispatch(FinalizarSaida(_entrada)))
        ],        

      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SaidaBloc, SaidaState>(
      bloc: bloc,
      builder: (BuildContext context, SaidaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = Center(child: ResultRender.renderLoading());
        }
        else if (state is StateCalcularSaida) {
          _entrada = state.entrada;
          _tabelas = state.tabelas;
          //_selectedTabela = _tabelas.first;
          //entrada.tabelaId = _selectedTabela.id;
          //entrada.nomeTabela = _selectedTabela.nomeTabela;
          //entrada.formaPgto = 'Dinheiro';
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateUpdatePrecoSaida) {
          _entrada = state.entrada;        
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateSuccess) {
          bodyWidget = ResultRender.renderSuccess('Saída realizada com sucesso!');
          Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context, true));
        }
        else if (state is StateErrorCancel) {
          bodyWidget = ResultRender.renderFail(state.error);
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }                

        return bodyWidget;       
      }  
    );
  }  

  Widget _renderInitial() {
    
    if (_entrada != null) {
      return ListView(children: <Widget>[    

        ListTile(
          leading: Icon(MdiIcons.car),
          title: Text(_entrada.placa),
          subtitle: _entrada.isMensalista ? Text('MENSALISTA') : Text(_entrada.modelo.isNotEmpty ? _entrada.modelo : '<não detectado>')
        ),

        ListTile(
          leading: Icon(MdiIcons.arrowRightCircleOutline),
          title: Text('Entada'),
          subtitle: Text(_entrada.getdataLocal()),
        ),
        
        ListTile(
          leading: Icon(MdiIcons.arrowLeftCircleOutline),
          title: Text('Saída'),
          subtitle: Text(_entrada.getdataSaidaLocal()),
        ),

        ListTile(
          leading: Icon(MdiIcons.clockOutline),
          title: Text('Tempo Total'),
          subtitle: Text('${Utils.minutesToHourExtension(_entrada.tempoTotal)} (${_entrada.tempoTotal.toString()} minutos)'),
        ), 

        if (!_entrada.isMensalista)
          ListTile(
            leading: Icon(MdiIcons.coin),
            title: Text('Preço total', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_entrada.getvalorTotal() ?? 'Selecione tabela de preço' , style: TextStyle(fontWeight: FontWeight.bold)),
          ),         

        if (!_entrada.isMensalista) _showTabelaPreco(),   
        
        if (!_entrada.isMensalista) _showFormaPgto()
      ],);
    }
    else {
      return Center(child: CircularProgressIndicator());
    }
  }
 
  Widget _showTabelaPreco() {
    List<Widget> lista = List<Widget>();

    _tabelas.forEach((tabela) {
      lista.add(
        Container(
          margin: EdgeInsets.only(right: 10 ),
          child: ChoiceChip(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            label: Text(tabela.nomeTabela),
            selected: tabela.id == _selectedTabela?.id,
            onSelected: (valor) {
              if (valor) {
                setState(() {
                  _selectedTabela = tabela;
                  _entrada.tabelaId = tabela.id;
                  bloc.dispatch(UpdatePrecoSaida(tabela.id, tabela.nomeTabela, _entrada));
                });
              }          
            },
          ) 
        )
      );
    });
    
    return ListTile(
      leading: Icon(Icons.folder_open),
      title: Text('Tabela Preço'),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: lista)
      ),
    );
  }

  Widget _showFormaPgto() {
    List<Widget> lista = List<Widget>();

    formasPgto.forEach((formaPgto) {
      lista.add(
        Container(
          margin: EdgeInsets.only(right: 10),
          child: ChoiceChip(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            label: Text(formaPgto),
            selected: _entrada.formaPgto == formaPgto,
            onSelected: (valor) {
              if (valor) {
                setState(() {
                  _entrada.formaPgto = formaPgto;
                  bloc.dispatch(UpdateFormaPgto(formaPgto, _entrada));
                });
              }          
            },
          ) 
        )
      );
    });

    return ListTile(
      leading: Icon(MdiIcons.cardsVariant),
      title: Text('Forma Pgto'),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: lista)
      ),
    );
  }  


}