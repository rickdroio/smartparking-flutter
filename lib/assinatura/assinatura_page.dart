import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smartparking_flutter2/model/subscription_model.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import 'bloc/assinatura_event.dart';
import 'bloc/assinatura_state.dart';
import 'bloc/assinatura_bloc.dart';

import 'dart:async';

class AssinaturaPage extends StatefulWidget {

  @override
  _AssinaturaPageState createState() => _AssinaturaPageState();
}

class _AssinaturaPageState extends State<AssinaturaPage> {

  final AssinaturaBloc bloc = AssinaturaBloc();
  List<Subscription> _subscriptions;
  Subscription _subscriptionAtual;

  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    bloc.dispatch(LoadInitial());

    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print('STREAM PURCHASE UPDATED');
      print(purchaseDetailsList.toString());
    }, onDone: () {
      print('STREAM PURCHASE ON DONE');
    }, onError: (error) {
      print('STREAM PURCHASE ERROR');
    }); 

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
      appBar: AppBar(
        title: Text('Assinatura'),
      ),
      body: _buildBody(),      
    );  
  }

  Widget _buildBody() {
    return BlocListener<AssinaturaBloc, AssinaturaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is StateError){
          ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red);
        }    
      },
      child: BlocBuilder<AssinaturaBloc, AssinaturaState>(
        bloc: bloc,
        builder: (BuildContext context, AssinaturaState state) {
          Widget bodyWidget = _renderInitial();

          if (state is StateLoading) {
            bodyWidget = ResultRender.renderLoading();
          }
          else if (state is StateLoadInitial) {
            _subscriptions = state.subscriptions;
            _subscriptionAtual = state.subscriptionAtual;
            //bloc.dispatch(InitialEvent());
          } 
          else if (state is StateSuccess) {
            bodyWidget = ResultRender.renderSuccess('Caixa finalizado com sucesso!');
            Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
          }           

          return bodyWidget;       
        }  
      )
    );
  }    

  /*
  Widget _buildBody() {
    return BlocBuilder<AssinaturaBloc, AssinaturaState>(
      bloc: bloc,
      builder: (BuildContext context, AssinaturaState state) {
        Widget bodyWidget = _renderInitial();

        if (state is StateLoadInitial) {
          _subscriptions = state.subscriptions;
          _subscriptionAtual = state.subscriptionAtual;
          bloc.dispatch(InitialEvent());
        }        
        else if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }          
        else if (state is StateSuccess) {
          bodyWidget = ResultRender.renderSuccess('Caixa finalizado com sucesso!');
          Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
        }
        else if (state is StateError){
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }

        return bodyWidget;
      }
    );
  } 
  */
  
  Widget _renderInitial() {
    List<Widget> lista = List<Widget>();

    lista.add(_renderAssinaturaAtual(_subscriptionAtual));

    if (_subscriptions != null) {
      _subscriptions.forEach((subscription) {
        lista.add(_renderSubscription(subscription));
      });
    }

    return ListView(children: lista);
  }

  Widget _renderSubscription(Subscription subscription) {
    return SizedBox(
      //height: 300,
      child: Card(margin: EdgeInsets.all(15), color: Colors.grey[300], child: Column(children: <Widget>[
 
        ListTile(
          leading: Icon(MdiIcons.tagMultiple) ,
          title: Text(subscription.nome, style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text('Mensal'),
        ),
        ListTile(
          leading: Icon(MdiIcons.carMultiple) ,
          title: Text(subscription.descricao),
        ),      
        ListTile(
          leading: Icon(MdiIcons.coin) ,
          title: Text('${subscription.preco} / mês', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),

        Text('Cancele quando quiser.'),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: RaisedButton.icon(
            color: Colors.green[800],
            textColor: Colors.white,
            icon: Icon(MdiIcons.cart),
            label: Text('Comprar'),
            onPressed: () {
              bloc.dispatch(ComprarAssinatura(subscription));
            },
          )
        )       

      ])),
    );
  }  

  Widget _renderAssinaturaAtual(Subscription subscription) {
    if (subscription == null) {
      return SizedBox(child: ResultRender.renderLoading(), height: 100,);
    }
    else if (!subscription.ativo) {
      return SizedBox(
        child: Card(margin: EdgeInsets.all(5), child: Column(children: <Widget>[
          Container(
            color: Colors.red,
            child: ListTile(
              leading: Icon(MdiIcons.cancel, color: Colors.white,) ,
              title: Text('Nenhuma assinatura ativa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
              //subtitle: Text(subscription.periodo, style: TextStyle(color: Colors.white),),
            ),
          ),
        ])),
      );      
    }
    else {
      return SizedBox(
        //height: 300,
        child: Card(margin: EdgeInsets.all(5), color: Colors.grey[300], child: Column(children: <Widget>[
          Container(
            //color: subscription.ativo ? Colors.blue : Colors.red,
            child: ListTile(
              leading: Icon(MdiIcons.starBox) ,
              title: Text('Sua assinatura atual', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),

          ListTile(
            leading: Icon(MdiIcons.tagMultiple) ,
            title: Text(subscription.nome, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subscription.detalhes ?? ''),
          ),
          ListTile(
            leading: Icon(MdiIcons.carMultiple) ,
            title: Text(subscription.descricao),
          ),     
        
          SizedBox(
            width: double.infinity,
            height: 50,
            child: RaisedButton.icon(
              color: Colors.blue[800],
              textColor: Colors.white,
              icon: Icon(MdiIcons.settings),
              label: Text('Gerenciar minhas assinaturas'),
              onPressed: () {
                launch('http://play.google.com/store/account/subscriptions');
              },
            )
          )           
        
        ])),
      );
    }




  } 

}