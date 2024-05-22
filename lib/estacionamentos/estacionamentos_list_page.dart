import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import './bloc/estacionamento_bloc.dart';
import './bloc/estacionamento_state.dart';
import './bloc/estacionamento_event.dart';

import '../model/estacionamento.dart';

import './estacionamento_edit_page.dart';
import './estacionamento_users_page.dart';

class EstacionamentoListPage extends StatefulWidget {
  @override
  _EstacionamentoListPageState createState() => _EstacionamentoListPageState();
}

class _EstacionamentoListPageState extends State<EstacionamentoListPage> {
  final EstacionamentoBloc bloc = EstacionamentoBloc();
  List<Estacionamento> _estacionamentos;

  @override
  void initState() {
    bloc.dispatch(LoadInitialData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estacionamentos'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<EstacionamentoBloc, EstacionamentoState>(
      bloc: bloc,
      builder: (BuildContext context, EstacionamentoState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateInitialData) {
          _estacionamentos = state.items;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateError) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }         
        else if (state is StateSuccessNewEstacionamento) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _callEditPage();
            bloc.dispatch(InitialEvent());
          });            
        }

        return bodyWidget;       
      }  
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();
    if (_estacionamentos != null)
      _estacionamentos.forEach((doc) {
        lista.add(_detail(doc));      
      });    

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Estacionamento item) {
    return Container(
      child: Column(children: <Widget>[
        ListTile(
          leading: Icon(Icons.place),
          title: Text(item.nome),
          subtitle: item.ativo ?? false ? Text('Ativo', style: TextStyle(color: Colors.green)) : Text('Desativado', style: TextStyle(color: Colors.red)),
          trailing: FlatButton(            
            child: Icon(Icons.more_vert),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EstacionamentoUsersPage(item.id))),
          ),
          onTap: () {
            _callEditPage(estacionamentoId: item.id);
          },
        ),
      ],) 
    );
  }   

  Widget _floatActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => bloc.dispatch(NewEstacionamento()),
    );
  }  

  void _callEditPage({String estacionamentoId}) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EstacionamentoEditPage(estacionamentoId)));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(LoadInitialData());
    }
  }     
   

}