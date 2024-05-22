import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/result_render.dart';

import './bloc/usuario_bloc.dart';
import './bloc/usuario_state.dart';
import './bloc/usuario_event.dart';

import '../model/usuario_model.dart';
import './usuario_edit_dialog.dart';
import './usuario_convite_page.dart';
import '../model/convite_model.dart';

class UsuariosListPage extends StatefulWidget {
  @override
  _UsuariosListPageState createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListPage> {
  final UsuarioBloc bloc = UsuarioBloc();
  List<Usuario> _usuarios;
  List<Convite> _convites;

  @override
  void initState() {
    bloc.dispatch(LoadInitialData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
      ),
      body: _buildBody(),
      floatingActionButton: _floatActionButton(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<UsuarioBloc, UsuarioState>(
      bloc: bloc,
      builder: (BuildContext context, UsuarioState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateInitialData) {
          _usuarios = state.items;
          _convites = state.convites;
          bloc.dispatch(InitialEvent());
        }        

        return bodyWidget;       
      }  
    );
  }

  Widget _renderInitial() {
    final List<Widget> lista = List<Widget>();
    if (_usuarios != null){
      _usuarios.forEach((doc) {
        lista.add(_detail(doc));      
      });
    }

    if (_convites != null){
      _convites.forEach((doc) {
        lista.add(_detailConvite(doc));      
      });
    }

    if (lista.length > 0)
      return ListView(children: lista);
    else
      return ResultRender.renderNoItemList();
  }

  Widget _detail(Usuario item) {
    return Container(
      child: Column(children: <Widget>[
        ListTile(
          leading: item.getUserAvatar(),
          title: Text(item.nome),
          trailing: FlatButton(
            child: Icon(Icons.more_vert),
            onPressed: () => _editTipoUsuario(item),
          ),
          subtitle: Text(item.telefone)
        ),
      ],) 
    );
  }   

  Widget _detailConvite(Convite item) {
    return Container(
      child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.green, child: Text('?')),
          title: Text(item.nome),
          subtitle: Text(item.telefone),
          trailing: Chip(label: Text('não confirmado')),
        ),      
    );
  }    

  Widget _floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.add),
      label: Text('Convidar Membro'),
      onPressed: () {
        _callConvitePage(null);
      },
    );
  } 

  void _callConvitePage(String uid) async {
    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => UsuarioConvitePage()));
    if (result != null && result) { //se voltar true atualizar lista
      bloc.dispatch(LoadInitialData());
    }
  }  

  void _editTipoUsuario(Usuario item) {
    showDialog(context: context, builder: (_) {
      return UsuarioEditDialog(item);
    }).then((v) {
      if (v != null) {
        item.admin = v;  
        bloc.dispatch(SaveUser(item));
        bloc.dispatch(LoadInitialData());
      }
    });    
  }



}