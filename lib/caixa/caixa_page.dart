import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import 'bloc/caixa_event.dart';
import 'bloc/caixa_state.dart';
import 'bloc/caixa_bloc.dart';

import '../model/caixa_item_model.dart';
import '../model/caixa_model.dart';

class CaixaPage extends StatefulWidget {

  @override
  _CaixaPageState createState() => _CaixaPageState();
}

class _CaixaPageState extends State<CaixaPage> {

  final CaixaBloc bloc = CaixaBloc();
  Caixa caixa;
  List<CaixaItem> itemsCaixa; 
  bool _caixaNaoEncontrado = false; 

  @override
  void initState() {
    bloc.dispatch(GetCaixaAbertoEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatActionButton(),
      appBar: AppBar(
        title: Text('Caixa'),
      ),
      body: _buildBody(),      
    );  
  }

  Widget floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.check),
      label: Text('Finalizar'),
      onPressed: () {
        if (!_caixaNaoEncontrado)
          bloc.dispatch(FinalizarCaixaEvent(caixa, itemsCaixa));
      },
    );
  }    

  Widget _buildBody() {
    return BlocBuilder<CaixaBloc, CaixaState>(
      bloc: bloc,
      builder: (BuildContext context, CaixaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }          
        else if (state is StateGetCaixaAberto) {
          caixa = state.caixa;
          itemsCaixa = state.itemsCaixa;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateSuccess) {
          bodyWidget = ResultRender.renderSuccess('Caixa finalizado com sucesso!');
          Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateNenhumCaixa) {
          _caixaNaoEncontrado = true;
          bodyWidget = ResultRender.renderFail(state.error);
        }

        return bodyWidget;
      }
    );
  } 
  
  Widget _renderInitial() {   
    if (caixa != null) {
      return ListView(children: <Widget>[

        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text('Data Abertura'),
          subtitle: Text(caixa.getdataAbertura()),
        ),
        
        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text('Data Fechamento'),
          subtitle: Text(caixa.getdataFechamento()),
        ),

        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text('Valor Total'),
          subtitle: Text(caixa.getvalorTotal()),
        ),     

        _showItems()   

      ],);
    }
    else {
      return Center(child: CircularProgressIndicator());
    }
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

}