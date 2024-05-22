import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:package_info/package_info.dart';

import '../service/usuario_service.dart';
import '../model/usuario_model.dart';

import '../service/estacionamento_service.dart';
import '../service/assinatura_service.dart';
import '../model/estacionamento.dart';

import './select_estacionamento_dialog.dart';

import '../model/subscription_model.dart';
import '../model/assinatura_model.dart';
import '../service/subscription_service.dart';

import '../service/token_service.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  DashboardPage(this.onLogout);

  @override
  State<StatefulWidget> createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState extends State<DashboardPage> {

  String _version = '';
  Usuario _usuario;
  Estacionamento _estacionamento;
  Assinatura _assinatura;
  //List<Estacionamento> _estacionamentosUsuario;
  Stream<DocumentSnapshot> _estacionamentoRef;
  Subscription _subscription;
  Flushbar _flushTrial;

  @override
  void initState() {
    getInitialEstacionamentoRef();
    getInitialStatus();
    getSubscription();
    
    super.initState();
  }

  void getInitialEstacionamentoRef() async {
    /*
    DocumentReference docRef = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    print('!!!!!!!!!!!!! SET ESTACIONAMENTO REF !!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    Stream<DocumentSnapshot> estacionamentoRef = docRef.snapshots();
    setState(() {
      _estacionamentoRef = estacionamentoRef;
    });
    */
  }

  void getInitialStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    
    Usuario usuario = await UsuarioService.getUsuarioLogado();
    

    if (await AssinaturaService.isPrimeiroAcesso()) {
      Flushbar(
        duration: Duration(seconds: 10),
        title: 'Bem-vindo ao MicroParking',
        message: 'Parabéns, seja muito bem-vindo à nossa família! Siga nossos tutoriais para começar a utilizar o app.',
        icon: Icon(MdiIcons.carMultiple, size: 28.0, color: Colors.blue[300]),
        //mainButton: FlatButton(child: Text('Acessar', style: TextStyle(color: Colors.amber),),),
      ).show(context);
    }

    setState(() {
      _version = packageInfo.version;
      _usuario = usuario;
    });
  }

  void getSubscription() async {
    Subscription subscription = await SubscriptionService.getSubscriptionUsuarioLogado(); //TODO - erro no primeiro LOGIN
    Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();
    Estacionamento estacionamento = await EstacionamentoService.getEstacionamentoUsuarioLogado();
    //bool primeiroAcesso = await AssinaturaService.isPrimeiroAcesso();

    /*
    if (!primeiroAcesso && subscription != null && subscription.idProduct == SubscriptionService.SKU_TRIAL) {    
      _flushTrial = Flushbar(
        //duration: Duration(seconds: 10),
        title: subscription.nome,
        message: subscription.periodo,
        icon: Icon(MdiIcons.information, size: 28.0, color: Colors.red[300]),
        mainButton: FlatButton(child: Text('Dispensar', style: TextStyle(color: Colors.amber),), onPressed: () => _flushTrial.dismiss(true),),
      )..show(context);
    }
    */

    setState(() {
      _subscription = subscription;
      _assinatura = assinatura;
      _estacionamento = estacionamento;
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(APP_TITLE)),
      drawer: _buildSideDrawer(context),
      body: _renderInitial()
    );
  }

  Widget _renderInitial() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 180,
        child: Card(margin: EdgeInsets.all(15), child: Column(children: <Widget>[
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(MdiIcons.carMultiple)) ,
            title: Text('Estacionados', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Container(
            margin: EdgeInsets.all(15),
            child: _capacidadeValue()
          )          
        ])),
      ),

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
      ),                  
      
    ],);
  }

  Widget _buildSideDrawer(BuildContext context){

    bool usuarioAdmin = (_usuario != null && _usuario.admin != null &&_usuario.admin);
    
    List<Widget> menus = List<Widget>();

    List<Widget> otherAccount = List<Widget>(); //mostrar icon estrela se for admin
    if (usuarioAdmin)
      otherAccount.add(Icon(Icons.star,color: Colors.yellow));

    menus.add(
      UserAccountsDrawerHeader(
        currentAccountPicture: Icon(Icons.account_circle, size: 50.0, color: Colors.white),
        accountName: _usuario != null ? Text(_usuario.nome) : Text('carregando...'),
        accountEmail: _usuario != null ? Text(_usuario.email) : Text('carregando...'), 
        otherAccountsPictures: otherAccount,
      )
    );

    menus.add(
      ListTile(
        leading: Icon(Icons.star),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Estacionamento Ativo', style: TextStyle(fontSize: 10, color: Colors.grey)), 
          _estacionamento != null ? Text(_estacionamento.nome) : Text('carregando...'), 
        ]),
        trailing: Text('Mudar'),
        onTap: () => _callMudarEstacionamentoAtivo()
      )
    );  

    menus.add(Divider());
    menus.add(_callPageWidget(context, 'Entrada', '/entrada', MdiIcons.arrowRightCircleOutline, true, true));
    menus.add(_callPageWidget(context, 'Saída', '/saidaManual', MdiIcons.arrowLeftCircleOutline, true, true));    
    menus.add(_callPageWidget(context, 'Lista Pátio', '/saida', MdiIcons.formatListBulleted, true, true));
    menus.add(_callPageWidget(context, 'Consulta Caixa', '/caixaConsulta', MdiIcons.fileFind, true, true));

    if (usuarioAdmin) {
      menus.add(Divider());
      menus.add(_callPageWidget(context, 'Caixa', '/caixa', MdiIcons.cashRegister, true, true));
      menus.add(_callPageWidget(context, 'Mensalistas', '/mensalista', MdiIcons.carMultiple, true, true));

      menus.add(
        ListTile(
          leading: Icon(MdiIcons.tagMultiple),
          title: Text('Assinatura'),
          onTap: () => _callAssinaturaPage(),
        )        
      );
      //menus.add(_callPage(context, 'Assinatura', '/assinatura', MdiIcons.tagMultiple, false));

      menus.add(_callPageWidget(context, 'Configurações', '/configlocal', MdiIcons.cellphoneSettingsVariant, false, false));
      menus.add(_callPageWidget(context, 'Tabela Preços', '/tabela', MdiIcons.coin, true, true));       

      menus.add(
        ListTile(
          leading: Icon(Icons.place),
          title: Text('Estacionamentos'),
          onTap: () => _callEstacionamentoPage(),
        )        
      );      

      menus.add(_callPageWidget(context, 'Usuários', '/usuario', Icons.supervised_user_circle, true, false));
    }

    menus.add(_signOutMenu());
    menus.add(Divider());

    menus.add(_callPageWidget(context, 'Termos de serviço', '/privacy', Icons.lock_outline, false, false));

    menus.add(
      ListTile(
        title: Text('Versão $_version'),
      )
    );

    return Drawer(
      child: ListView(children: menus),
    );
  }

  Future _callMudarEstacionamentoAtivo() async {
    List<Estacionamento> estacionamentosUsuario = await EstacionamentoService.getEstacionamentosUsuarioLogado();
    SelectEstacionamentoDialog(estacionamentosUsuario).dialog(context).then((String estacionamentoId) {
      if (estacionamentoId.isNotEmpty) {
        EstacionamentoService.setEstacionamentoProperty(estacionamentoId);
        getInitialEstacionamentoRef();
        getSubscription();
      }            
    });
  }

  Widget _callPageWidget(BuildContext context, String title, String path, IconData icon, bool secure, bool estacionamentoAtivo) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _callPage(path, secure, estacionamentoAtivo)
    ); 
  }

  void _callPage(String path, bool secure, bool estacionamentoAtivo) {
    //secure = se pode entrar com assinatura vencida
    //estacionamentoAtivo = se pode entrar se estacionamento estiver ativo apenas

    print('require SECURE = ${secure.toString()}');
    print('require estacionamentoAtivo = ${estacionamentoAtivo.toString()}');
    print('estacionamento.ativo = ${_estacionamento.ativo.toString()}');
    print('assinatura.estacionamentosAtivos = ${_assinatura.estacionamentosAtivos.toString()}');
    print('subscription.qtdeEstacionamentos = ${_subscription.qtdeEstacionamentos.toString()}');

    if (estacionamentoAtivo && !_estacionamento.isAtivo()) //se for obrigatorio ter est ativo e nao estiver
      _estacionamentoNaoAtivoMessage();
    else if (secure)
      _securityCallRouter(path);
    else if (_assinatura.estacionamentosAtivos > _subscription.qtdeEstacionamentos)
      _estacionamentoQtde();
    else 
      Navigator.pushNamed(context, path);
  }

  void _callAssinaturaPage() async {    
    await Navigator.pushNamed(context, '/assinatura');
    getSubscription(); //atualizar sempre - caso tenha uma compra
  }

  void _callEstacionamentoPage() async {    
    await Navigator.pushNamed(context, '/estacionamento');
    getSubscription(); //atualizar sempre - caso tenha uma compra
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

  Widget _capacidadeValue() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _estacionamentoRef,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {  
        //print('estacionados state = ${snapshot.connectionState.toString()}');
        //print('snapshot.hasData = ${snapshot.hasData.toString()}');
        //print('snapshot.data.exists = ${snapshot.data.exists.toString()}');   

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

  Widget cardBotao(String title, String subtitle, IconData icone, double marginTop) {
    return Card(
      margin: EdgeInsets.only(left: 15, right: 15, top: marginTop),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(icone)),
        title: Text(title),
        subtitle: Text(subtitle),
      )
    );
  }

  void _securityCallRouter(String page) async {
    if (_subscription.ativo) Navigator.pushNamed(context, page);
    else {
      Flushbar(
        duration: Duration(seconds: 5),
        title: 'Assinatura expirada',
        message: 'Verifique as configurações de assinatura',
        icon: Icon(MdiIcons.information, size: 28.0, color: Colors.red[300]),
      ).show(context);
    }
  }

  void _estacionamentoNaoAtivoMessage() async {
    Flushbar(
      duration: Duration(seconds: 5),
      title: 'Esse estacionamento está desativado',
      message: 'Verifique as configurações para ativar ele',
      icon: Icon(MdiIcons.information, size: 28.0, color: Colors.red[300]),
    ).show(context); 
  }

  void _estacionamentoQtde() async {
    Flushbar(
      duration: Duration(seconds: 5),
      title: 'Quantidade de estacionamentos ativo maior que o contratado',
      message: 'Verifique as configurações de assinatura',
      icon: Icon(MdiIcons.information, size: 28.0, color: Colors.red[300]),
    ).show(context); 
  }

}