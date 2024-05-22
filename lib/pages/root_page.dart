import 'package:flutter/material.dart';
import '../model/login_model.dart';
import '../service/usuario_service.dart';
import '../login/login_page.dart';
import '../dashboard/dashboard_page.dart';
import '../service/configuracoes_local_service.dart';


//https://stackoverflow.com/questions/52080852/using-sharedpreferences-to-set-login-state-and-retrieving-it-at-app-launch-flu/52081029#52081029
//usar FUTURE BUILDER para quando sair pela plataforma

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  //String androidId;

  @override
  void initState() {
    asyncInitState();
    super.initState();
  }

  void asyncInitState() async {
    //androidId = await DeviceService.androidId();
    bool usuarioAtivo = await UsuarioService.usuarioAtivo();

    AuthStatus auth = usuarioAtivo ? AuthStatus.LOGGED_IN : AuthStatus.NOT_LOGGED_IN;
    if (auth == AuthStatus.NOT_LOGGED_IN) {
      //forçar que esteja realmente signOut
      UsuarioService.signOut();
    }
    
    setState(() {
      _authStatus = auth;
    });     


    //await FlutterInappPurchase.initConnection;

    //zerar assinaturaId em todo login, para nao ter problema de pegar valor de outro user
    //AssinaturaService.setAssinaturaProperty(null); >> foi pra tela de confirmacao de SMS

    //iniciar configuracoes defaults
    ConfiguracoesLocalService.setDefaults();

    //getItems();

    /*
    Query query = await DeviceService.getDeviceRef();
    query.snapshots().listen((data) {
      String newAndroidId = data.documents.first.data['androidId'];
      print('NEW DEVICE CONNECTED $newAndroidId');

      if (newAndroidId != null && newAndroidId != androidId) {
        //novo dispositivo novo diferente conectado
        print('novo dispositivo novo diferente conectado');
        _onLogout();
      }

    });
    */
  }  

  @override
  Widget build(BuildContext context) {
      print('ROOT BUILD');
      print(_authStatus.toString());
      if (_authStatus == AuthStatus.NOT_LOGGED_IN) {
        return LoginPage(_onLogin);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else if (_authStatus == AuthStatus.LOGGED_IN) {
        return DashboardPage(_onLogout);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
      }
      else {
        return _splash();
      }
  }

  void _onLogin(){
    setState(() {
      print('root = onLOGIN');
      _authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onLogout(){
    setState(() {
      print('root = onLOGOUT');
      _authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  @override
  void dispose() async {
    //await FlutterInappPurchase.endConnection;
    super.dispose();
  }

  Widget _splash() {
    return Scaffold(            
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            //decoration: BoxDecoration(color: Colors.lightBlue[200]),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  //shrinkWrap: true,
                  children: <Widget>[

                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 0.0),
                      child: Column(children: <Widget>[
                        Image.asset('images/appicon.png', width: 150),
                        Image.asset('images/microparking.png', height: 30,),
                      ],)
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 100, 0.0, 0.0),
                      child: Container(child: CircularProgressIndicator())
                    )

                  ],
              ),
            )  
          )
        ],
      )
    );
  }
}