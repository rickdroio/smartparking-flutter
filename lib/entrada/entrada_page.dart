import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smartparking_flutter2/widgets/camera_qrcode.dart' as prefix0;
import 'dart:async';

import '../widgets/result_render.dart';
import '../widgets/confirmation_dialog.dart';

import 'bloc/entrada_bloc.dart';
import 'bloc/entrada_event.dart';
import 'bloc/entrada_state.dart';
import '../model/entrada_model.dart';

import '../service/nfc_service.dart';

import '../model/tipo_entrada_model.dart';

import '../widgets/camera_placa.dart';
import '../widgets/camera_qrcode.dart';


class EntradaPage extends StatefulWidget {
  @override
  _EntradaPageState createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
  
  EntradaBloc bloc = EntradaBloc();
  final searchOnChange = new BehaviorSubject<String>();

  String _placaOld = '';
  final _placa = TextEditingController();
  String _modelo = '';
  String _restricao = '';

  bool _imprimir = true;

  TipoEntrada _tipoEntrada;
  String _entradaId;


  @override
  void initState() {
    bloc.dispatch(InitialEntrada());

    _placa.addListener(_onChangePlaca);
    searchOnChange
    .debounce((_) => TimerStream(true, const Duration(seconds: 1)))
    .listen((queryString){
      if (queryString.length>=7 && _placaOld != queryString) {
        bloc.dispatch(SearchPlaca(_placa.text));
      }
      _placaOld = queryString;   
    });
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
      floatingActionButton: floatActionButton(),
      appBar: AppBar(
        title: Text('Entrada'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.photo_camera), tooltip: 'Tirar foto', onPressed: (){
            _placa.clear();
            _callCamera();
            //_getPhoto();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPlaca()));
          },)
        ], 
      ),
      body: _buildBody()
    );  
  }

  Widget floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.check),
      label: Text('Entrada'),
      onPressed: () {
        if (_tipoEntrada == TipoEntrada.NFC_CARD) _showWriteNFC(context);
        if (_tipoEntrada == TipoEntrada.QRCODE_CARD) _qrCodeReading();
        if (_tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER) _imprimirQRCode();
      }      
    );
  }   

  Widget _buildBody() {
    return BlocBuilder<EntradaBloc, EntradaState>(
      bloc: bloc,
      builder: (BuildContext context, EntradaState state) {
        Widget bodyWidget = _renderInitial(false);
        
        if (state is StateLoading) {
          bodyWidget = ResultRender.renderLoading();
        }
        else if (state is StateModeloLoading) {
          bodyWidget = _renderInitial(true);
        }
        else if (state is StateModeloSuccess) {
          _modelo = state.sinesp.modelo;
          _restricao = state.sinesp.situacao;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateModeloError) {
          _modelo = 'não encontrado';
          _restricao = '';
          bloc.dispatch(InitialEvent());
        }

        else if (state is StateInitialEntrada) { 
          if (state.tipoEntrada == null) {
            bodyWidget = ResultRender.renderFail('Tipo de entrada não configurado');
          }
          else {
            _tipoEntrada = state.tipoEntrada;
            _entradaId = state.entradaId;
            bloc.dispatch(InitialEvent());
          }
        }

        else if (state is StateSuccess) {
          bodyWidget = ResultRender.renderSuccess('Sucesso !');
          Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
        }
        else if (state is StateError) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));
          bloc.dispatch(InitialEvent());
        }        

        return bodyWidget;
      }
    );
  }

  Widget _renderInitial(bool loadingModel) {
    return ListView(children: <Widget>[

      ListTile(
        leading: Icon(Icons.arrow_forward),
        title: Column(children: <Widget>[
          TextFormField(
            maxLength: 7,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: 'Placa'),
            controller: _placa,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))]
          ),
        ],)
      ),  

      ListTile(
        leading: !loadingModel ? Icon(MdiIcons.car) : CircularProgressIndicator(),
        title: Text(_modelo == '' ? '< Modelo Carro >' : _modelo),
        subtitle: Text(_restricao == '' ? 'Detectado automaticamente' : 'Restrição: $_restricao')
      ),

      if (_tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER)
        SwitchListTile(
          title: Text('Imprimir ticket'),
          value: _imprimir,
          onChanged: (bool value) { setState(() { _imprimir = value; }); },
          secondary: Icon(MdiIcons.checkDecagram),
        ),               

    ]);
  }

  void _initNFCReading(String placa, String modelo, TipoEntrada tipoEntradaFisico) {
    /*
    NfcService.readNFC().then((id) {
      print('LEITURA NFC $id');
      //bloc.dispatch(AddEntrada(placa, modelo, tipoEntradaFisico));
      NfcService.stopNFC();
    });
    */
  }

  void _qrCodeReading() async {
    final String qrCode = await Navigator.push(context, MaterialPageRoute(builder: (context) => CameraQRCode()));
    if (qrCode != null && qrCode.isNotEmpty) {
      print('QRCODE = $qrCode');
      bloc.dispatch(AddEntrada(
        Entrada(
          id: _entradaId,
          placa: _placa.text,
          modelo: _modelo,
          tipoEntrada: _tipoEntrada,
          tipoEntradaId: qrCode
        ),
      ));            
    }
  }

  void _imprimirQRCode() {
    bloc.dispatch(AddEntrada(
      Entrada(
        id: _entradaId,
        placa: _placa.text,
        modelo: _modelo,
        tipoEntrada: _tipoEntrada,
      ),
      imprimir: _imprimir
    ));
  }

  void _onChangePlaca() {
    searchOnChange.add(_placa.text);
  }

  void _showWriteNFC(context){

    NfcService.writeNFC(_entradaId).listen((response) {
      print('NFC GRAVADO');
      bloc.dispatch(AddEntrada(
        Entrada(
          id: _entradaId,
          placa: _placa.text,
          modelo: _modelo,
          tipoEntrada: _tipoEntrada,
        )
      ));
      Navigator.pop(context);
    });

    final bottomSheet = showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Column(children: <Widget>[
          ListTile(
            leading: new Icon(Icons.nfc),
            title: new Text('Aproxime o cartão'),
          ),
          Image.asset('images/nfc.png'),
        ]);
      }
    );

    bottomSheet.whenComplete(() => NfcService.stopNFC());
  } 

  void _callCamera() async {
    final String placaIdentificada = await Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPlaca()));    
    if (placaIdentificada != null && placaIdentificada.isNotEmpty) {
      _placa.text = placaIdentificada;      
    }
  }    

}