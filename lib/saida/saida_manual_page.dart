import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smartparking_flutter2/model/tipo_entrada_model.dart';
import 'package:smartparking_flutter2/widgets/result_render.dart';

import 'saida_page.dart';
import 'saida_lista_page.dart';

import 'bloc/saida_bloc.dart';
import 'bloc/saida_event.dart';
import 'bloc/saida_state.dart';

import '../service/nfc_service.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/camera_qrcode.dart';

class SaidaManualPage extends StatefulWidget {
  @override
  _SaidaManualPageState createState() => _SaidaManualPageState();
}

class _SaidaManualPageState extends State<SaidaManualPage> {
  final SaidaBloc bloc = SaidaBloc();
  TipoEntrada _tipoEntrada;

  @override
  void initState() {
    bloc.dispatch(InitSaidaManual());
    super.initState();
  }

  @override
  void dispose() {
    NfcService.stopNFC();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingActionButton: floatActionButton(),     
      appBar: AppBar(
        title: Text('Saída'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(MdiIcons.arrowRightCircleOutline, color: Colors.white,), 
            label: Text('Lista Pátio', style: TextStyle(color: Colors.white)), 
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SaidaListaPage())));
            },)
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
        else if (state is StateError) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }   
        else if (state is StateInitSaidaManual) {
          _tipoEntrada = state.tipoEntrada;
          if (state.tipoEntrada == null) {
            bodyWidget = ResultRender.renderFail('Tipo de entrada não configurado');
          }
          else {
            if (state.tipoEntrada == TipoEntrada.QRCODE_CARD || state.tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _initQRCodeReading()); 
            }
            else if (state.tipoEntrada == TipoEntrada.NFC_CARD) {
              _initNFCReading();
            }

            bloc.dispatch(InitialEvent());            
          }

        }
        else if (state is StateSaidaManualSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _callSaidaPage(state.idEntrada));          
        }

        return bodyWidget;
      }  
    );
  }  

  Widget _renderInitial() {

    Widget item;

    if (_tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER || _tipoEntrada == TipoEntrada.QRCODE_CARD) {
      item = Container(
        margin: EdgeInsets.all(30),
        child: SizedBox(
          height: 80,
          child: RaisedButton.icon(
            label: Text('Escanear QR CODE', style: TextStyle(color: Colors.white),), 
            icon: Icon(MdiIcons.qrcodeScan, color: Colors.white,),
            onPressed: () => _initQRCodeReading()
          )
        )
      );
    }
    if (_tipoEntrada == TipoEntrada.NFC_CARD) {
      item = Column(children: <Widget>[
        ListTile(
          leading: new Icon(Icons.nfc),
          title: new Text('Aproxime o cartão'),
        ),
        Image.asset('images/nfc.png'),
        FlatButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('CANCELAR'),
          onPressed: () {
            NfcService.stopNFC();
            bloc.dispatch(InitialEvent());
          },
        )
      ]);      
    }
    else
      item = ResultRender.renderLoading();

    return ListView(children: <Widget>[item],);
  }

  void _initNFCReading() {
    /*
    NfcService.readNFC().then((id) {
      print('LEITURA NFC $id');
      //bloc.dispatch(ProcurarIdFisico(id));
    });
    */
  }

  void _initQRCodeReading() async {
    final String qrCode = await Navigator.push(context, MaterialPageRoute(builder: (context) => CameraQRCode()));
    if (qrCode != null && qrCode.isNotEmpty) {
      print('QRCODE = $qrCode');
      if (_tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER)
        bloc.dispatch(SaidaProcurarEntradaId(qrCode));
      else
      if (_tipoEntrada == TipoEntrada.QRCODE_CARD)
        bloc.dispatch(SaidaProcurarTipoEntradaId(qrCode));          
    }
  }

  void _callSaidaPage(String entradaId) async {
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SaidaPage(entradaId)));
  }  

}