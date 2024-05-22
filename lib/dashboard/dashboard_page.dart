import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';
import 'bloc/dashboard_bloc.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/result_render.dart';
import '../service/token_service.dart';

import '../model/usuario_model.dart';
import '../model/estacionamento.dart';
import '../model/subscription_model.dart';
import '../model/assinatura_model.dart';

import '../service/estacionamento_service.dart';
import '../service/printer_service2.dart';
import '../service/usuario_service.dart';

import './select_estacionamento_dialog.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  DashboardPage(this.onLogout);  

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardBloc bloc = DashboardBloc();

  Usuario _usuario;
  Estacionamento _estacionamento;
  Assinatura _assinatura;
  Stream<DocumentSnapshot> _estacionamentoStream;
  Subscription _subscription;
  String _appVersion;

  PrinterService printer = PrinterService();

  @override
  void initState() {
    bloc.dispatch(LoadInitialData());    
    super.initState();
  }  

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(APP_TITLE)),
      drawer: _renderSideDrawer(context),
      body: _buildBody()
    );
  }   

  Widget _buildBody() {
    return BlocListener<DashboardBloc, DashboardState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }
        else if (state is StateInitialData) {
          if (!state.subscription.ativo) 
            ConfirmationDialog.snackbar(context: context, titulo:ASSINATURA_EXPIRADA, mensagem: GENERAL_VERIFIQUE_CONFIGS, cor: Colors.red, duration: 20);            
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        bloc: bloc,
        builder: (BuildContext context, DashboardState state) {
          Widget bodyWidget = ResultRender.renderLoading();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }
          else if (state is StateInitialData) {
            _appVersion = state.appVersion;
            _usuario = state.usuario;
            _estacionamento = state.estacionamento;
            _assinatura = state.assinatura;
            _estacionamentoStream = state.estacionamentoStream;
            _subscription = state.subscription;

            bodyWidget = _renderInitial();
          }

          return bodyWidget;
        }  
      )
    );
  }  

  Widget _renderInitial() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 180,
        child: Card(margin: EdgeInsets.all(10), child: Column(children: <Widget>[
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(MdiIcons.carMultiple)) ,
            title: Text('Estacionados', style: TextStyle(fontWeight: FontWeight.bold),),
            trailing: GestureDetector(
              child: Text('ver detalhes', style: TextStyle(color: Colors.blue)),
              onTap: () => _callPage('/saida'),
            ) 
          ),

          Container(
            margin: EdgeInsets.all(15),
            child: _capacidadeValue()
          ),

        ])),
      ),

      /*
      GestureDetector(
        child: cardBotao('Entrada', 'Clique aqui para fazer entrada de carros', MdiIcons.arrowRightCircleOutline, 20),
        onTap: () => _callPage('/entrada', true, true)
      ),

      GestureDetector(
        child: cardBotao('Saída', 'Clique aqui para fazer saída de carros', MdiIcons.arrowLeftCircleOutline, 10),
        onTap: () => _callPage('/saidaManual', true, true)
      ),  

      GestureDetector(
        child: cardBotao('Lista Pátio', 'Clique aqui para vizualizar o pátio', MdiIcons.formatListBulleted, 10),
        onTap: () => _callPage('/saida', true, true)
      ),  */   

      FlatButton(
        child: Text('CONECTAR'),
        onPressed: () {
          imprimirTeste();          
        },
      ),
      FlatButton(
        child: Text('IS CONNECTED'),
        onPressed: () {
          print(printer.isConnected);
        },
      ),
      FlatButton(
        child: Text('DISCONNECT'),
        onPressed: () {
          printer.disconnect().then((_){
            print('TEST: connection cancelled');
          });
        },
      ),

         
      
    ],);
  }

  void imprimirTeste() async {
    await printer.connect();
    printer.write('TETETTSTSTTETSTTSTETTETETETTETETETETTETET TETT ET TETETT ET ETTE T TE ');
    //printer.finish();

    //printer.write('AOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO TETT ET TETETT ET ETTE T TE ');
    //printer.write('TETETTSTSTTETSTTSTETTETETETTETETETETTETET TETT ET TETETT ET ETTE T TE ');
    //await printer.disconnect();
  }

  Widget _capacidadeValue() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _estacionamentoStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {  
        print('snapshot state = ${snapshot.connectionState.toString()}');
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }      

        if (!snapshot.hasData) {
          print('!snapshot.hasData');
          return CircularProgressIndicator();
        } 

        if (!snapshot.data.exists) {
          print('!snapshot.data.exists');
          return CircularProgressIndicator();
        }

        double porcVagas = 0;
        String porcVagasDesc = '';           

        switch (snapshot.connectionState) { 
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:   
            Estacionamento estacionamento = Estacionamento.of(snapshot.data);
            int totalEntradasAberto = estacionamento.totalEntradasAberto ?? 0;
            if (estacionamento.capacidade == 0) {
              porcVagas = 0;
              porcVagasDesc = 'Total = ${totalEntradasAberto.toString()}';
            }
            else {
              porcVagas = totalEntradasAberto / estacionamento.capacidade;
              porcVagasDesc = '${totalEntradasAberto.toString()} / ${estacionamento.capacidade.toString()}';
            }     
            return LinearPercentIndicator( 
              animation: true,
              lineHeight: 30,
              percent: porcVagas,
              center: Text(porcVagasDesc, style: TextStyle(color: Colors.white),),
              progressColor: Colors.green,
            ); 
          }
      });

    }  

  Future _callPage(String path, {bool assinaturaAtiva = true, bool estacionamentoAtivo = true, bool dispatchInitial = false}) async {
    //secure = se pode entrar com assinatura vencida
    //estacionamentoAtivo = se pode entrar se estacionamento estiver ativo apenas

    if (estacionamentoAtivo && !_estacionamento.isAtivo()) //se for obrigatorio ter est ativo e nao estiver
      ConfirmationDialog.snackbar(context: context, titulo:ESTACIONAMENTO_DESATIVADO, mensagem: GENERAL_VERIFIQUE_CONFIGS, cor: Colors.red);
    else if (estacionamentoAtivo && _assinatura.estacionamentosAtivos > _subscription.qtdeEstacionamentos)
      ConfirmationDialog.snackbar(context: context, titulo:ESTACIONAMENTO_QTDE, mensagem: GENERAL_VERIFIQUE_CONFIGS, cor: Colors.red);
    else if (assinaturaAtiva && !_subscription.ativo)
      ConfirmationDialog.snackbar(context: context, titulo:ASSINATURA_EXPIRADA, mensagem: GENERAL_VERIFIQUE_CONFIGS, cor: Colors.red);      
    else if (dispatchInitial) {
      await Navigator.pushNamed(context, path);
      bloc.dispatch(LoadInitialData());
    }
    else 
      Navigator.pushNamed(context, path);
  }    

  Widget _renderSideDrawer(BuildContext context){
    return BlocBuilder<DashboardBloc, DashboardState>(
      bloc: bloc,
      builder: (BuildContext context, DashboardState state) {
        Widget bodyWidget = _renderLoadingDrawer();

        //if (state is StateLoading) {
        //  bodyWidget = Drawer(child: ListView(children: [ResultRender.renderLoading()]));    
        //}
        if (state is StateInitialData) {
          bodyWidget = _renderInitialDrawer(state.usuario.admin);
        }

        return bodyWidget;
      }  
    );
   }

   Widget _renderLoadingDrawer() {
    List<Widget> menus = List<Widget>();

    menus.add(
      UserAccountsDrawerHeader(
        currentAccountPicture: ResultRender.renderLoading(),
        accountName: _usuario != null ? Text(_usuario.nome) : Text(GENERAL_CARREGANDO),
        accountEmail: _usuario != null ? Text(_usuario.email) : Text(GENERAL_CARREGANDO), 
      )
    );

    menus.add(Center(child: ResultRender.renderLoading()));

    return Drawer(child: ListView(children: menus));
   }

  Widget _renderInitialDrawer(bool usuarioAdmin) { 

    List<Widget> menus = List<Widget>();
    List<Widget> otherAccount = List<Widget>(); //mostrar icon estrela se for admin
    if (usuarioAdmin) otherAccount.add(Icon(Icons.star, color: Colors.yellow));

    //Informacao usuario
    menus.add(
      UserAccountsDrawerHeader(
        currentAccountPicture: Icon(MdiIcons.accountCheck, size: 40, color: Colors.white),
        accountName: Text(_usuario.nome),
        accountEmail: Text(_usuario.telefone), 
        otherAccountsPictures: otherAccount,
      )
    );  

    //estacionamento ativo
    menus.add(
      ListTile(
        leading: Icon(Icons.label_important),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Estacionamento Ativo', style: TextStyle(fontSize: 10, color: Colors.grey)), 
          Text(_estacionamento.nome)
        ]),
        trailing: Text('Mudar'),
        onTap: () => _callMudarEstacionamentoAtivo()
      )
    );  
    
    menus.add(Divider());
    menus.add(_menuItem('Entrada', MdiIcons.arrowRightCircleOutline, '/entrada'));
    menus.add(_menuItem('Saída', MdiIcons.arrowLeftCircleOutline, '/saidaManual'));
    menus.add(_menuItem('Lista Pátio', MdiIcons.formatListBulleted, '/saida'));
    menus.add(_menuItem('Consulta Caixa', MdiIcons.fileFind, '/caixaConsulta'));   
    
    if (usuarioAdmin) {
      menus.add(Divider());
      menus.add(_menuItem('Caixa', MdiIcons.cashRegister, '/caixa')); 
      menus.add(_menuItem('Mensalistas', MdiIcons.carMultiple, '/mensalista')); 
      menus.add(_menuItem('Assinatura', MdiIcons.tagMultiple, '/assinatura', estacionamentoAtivo: false, assinaturaAtiva: false, dispatchInitial: true));
      menus.add(_menuItem('Tabela Preços', MdiIcons.coin, '/tabela'));
      menus.add(_menuItem('Estacionamentos', Icons.place, '/estacionamento', estacionamentoAtivo: false, dispatchInitial: true));
      menus.add(_menuItem('Usuários', Icons.supervised_user_circle, '/usuario', estacionamentoAtivo: false));
    }

    menus.add(_menuItem('Configurações', MdiIcons.cellphoneSettingsVariant, '/configlocal', 
      estacionamentoAtivo: false, assinaturaAtiva: false));     
    
    menus.add(_signOutMenu());
    menus.add(Divider());

    menus.add(_menuItem('Termos de serviço', Icons.lock_outline, '/privacy', estacionamentoAtivo: false, assinaturaAtiva: false));

    menus.add(
      ListTile(
        title: Text('Versão $_appVersion'),
      )
    );    

    return Drawer(
      child: ListView(children: menus),
    );    
  }

  Widget _menuItem(String title, IconData icon, String path, {bool assinaturaAtiva = true, bool estacionamentoAtivo = true, bool dispatchInitial = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _callPage(path, assinaturaAtiva: assinaturaAtiva, estacionamentoAtivo: estacionamentoAtivo)
    ); 
  }

  Widget _signOutMenu() {
    return ListTile(
      leading: Icon(MdiIcons.power),
      title: Text('Desconectar'),
      onTap: _signOutMenuClick,
    ); 
  }  

  void _signOutMenuClick() async {
    try {
      await UsuarioService.signOut();
      widget.onLogout();
    }
    catch (e) {
      print(e);
    }
  }  

  Future _callMudarEstacionamentoAtivo() async {
    List<Estacionamento> estacionamentosUsuario = await EstacionamentoService.getEstacionamentosUsuarioLogado();
    SelectEstacionamentoDialog(estacionamentosUsuario).dialog(context).then((String estacionamentoId) {
      if (estacionamentoId.isNotEmpty) {
        EstacionamentoService.setEstacionamentoProperty(estacionamentoId);
        bloc.dispatch(LoadInitialData());
      }            
    });
  }  
   
}