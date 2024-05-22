import 'package:flutter/material.dart';
import './pages/root_page.dart';
import './tabela/tabela_lista_page.dart';
import './entrada/entrada_page.dart';
import './saida/saida_lista_page.dart';
import './saida/saida_manual_page.dart';
import './caixa/caixa_lista_page.dart';
import './caixa/caixa_consulta_page.dart';
import './configuracoes_local/configuracoes_local_page.dart';
import './pages/privacy_page.dart';
import './assinatura/assinatura_page.dart';
import './estacionamentos/estacionamentos_list_page.dart';
import './usuarios/usuarios_list_page.dart';
import './mensalista/mensalista_list_page.dart';

void main() async {   
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
    Widget build(BuildContext context) {     
      return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple
        ),
        home: RootPage(),
        routes:  {
          //'/login': (BuildContext context) => LoginPage(),
          //'/dashboard': (BuildContext context) => DashboardPage(),
          '/tabela': (BuildContext context) => TabelaListaPage(),
          '/entrada': (BuildContext context) => EntradaPage(),
          '/saidaManual': (BuildContext context) => SaidaManualPage(),
          '/saida': (BuildContext context) => SaidaListaPage(),
          '/caixa': (BuildContext context) => CaixaListaPage(),
          '/caixaConsulta': (BuildContext context) => CaixaConsultaPage(),
          '/configlocal': (BuildContext context) => ConfiguracoesLocalPage(),
          '/privacy': (BuildContext context) => PrivacyPage(),
          '/assinatura': (BuildContext context) => AssinaturaPage(),
          '/estacionamento': (BuildContext context) => EstacionamentoListPage(),
          '/usuario': (BuildContext context) => UsuariosListPage(),
          '/mensalista': (BuildContext context) => MensalistaListPage(),
        },
      );
    }
}