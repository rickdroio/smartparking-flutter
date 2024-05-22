import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import './bloc/mensalista_bloc.dart';
import './bloc/mensalista_state.dart';
import './bloc/mensalista_event.dart';

import '../model/mensalista_model.dart';

import './mensalista_edit_page.dart';

class MensalistaListPage extends StatefulWidget {
  @override
  _MensalistaListPageState createState() => _MensalistaListPageState();
}

class _MensalistaListPageState extends State<MensalistaListPage> {
  final MensalistaBloc bloc = MensalistaBloc();
  List<Mensalista> _mensalistas;

  @override
  void initState() {
    bloc.dispatch(LoadInitialData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensalistas'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocListener<MensalistaBloc, MensalistaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }    
      },
      child: BlocBuilder<MensalistaBloc, MensalistaState>(
        bloc: bloc,
        builder: (BuildContext context, MensalistaState state) {
          Widget bodyWidget = _renderInitial();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }
          else if (state is StateInitialData) {
            _mensalistas = state.items;
            //bloc.dispatch(InitialEvent());
          }

          return bodyWidget;       
        }  
      )
    );
  }  

  /*  

  Widget _buildBody() {
    return BlocBuilder<MensalistaBloc, MensalistaState>(
      bloc: bloc,
      builder: (BuildContext context, MensalistaState state) {
        Widget bodyWidget = _renderInitial();
        
        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateInitialData) {
          _mensalistas = state.items;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateError) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }

        return bodyWidget;       
      }  
    );
  }
  */

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();
    if (_mensalistas != null)
      _mensalistas.forEach((doc) {
        lista.add(_detail(doc));      
      });    

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Mensalista item) {
    return Container(
      child: Column(children: <Widget>[
        ListTile(
          leading: Icon(MdiIcons.carMultiple),
          title: Text(item.placa),
          subtitle: Text(item.nome),
          onTap: () {
            _callEditPage(id: item.id);
          },
        ),
      ],) 
    );
  }

  Widget _floatActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => _callEditPage(),
    );
  }  

  void _callEditPage({String id}) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MensalistaEditPage(id)));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(LoadInitialData());
    }
  }     
   

}