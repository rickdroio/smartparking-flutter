import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smartparking_flutter2/service/printer_service.dart';

import '../widgets/confirmation_dialog.dart';

import 'bloc/configuracoes_local_event.dart';
import 'bloc/configuracoes_local_state.dart';
import 'bloc/configuracoes_local_bloc.dart';

import '../model/tipo_entrada_model.dart';

class ConfiguracoesLocalPage extends StatefulWidget {

  @override
  _ConfiguracoesLocalPageState createState() => _ConfiguracoesLocalPageState();
}

class _ConfiguracoesLocalPageState extends State<ConfiguracoesLocalPage> {

  final PrinterService printerService = PrinterService(notLoadPrinter: true);
  final ConfiguracoesLocalBloc bloc = ConfiguracoesLocalBloc();  
  List<BluetoothDevice> _devices;
  BluetoothDevice _printer;
  TipoEntrada _tipoEntrada;
  BuildContext _context;

  List<DropdownMenuItem<TipoEntrada>> _tiposEntrada = [];

  _ConfiguracoesLocalPageState() {
    TipoEntrada.values.forEach((tipo) {
      _tiposEntrada.add(
        DropdownMenuItem(child: Text(TipoEntradaUtils.getDescricao(tipo)), value: tipo),
      );
    });
    
    bloc.dispatch(InitConfiguracoes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'), 
      ),
      floatingActionButton: floatActionButton(),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ConfiguracoesLocalBloc, ConfiguracoesLocalState>(
      bloc: bloc,
      builder: (BuildContext context, ConfiguracoesLocalState state) {
        _context = context;
        Widget bodyWidget = _renderInitial();

        if (state is StateLoading) {
          bodyWidget = Center(child: CircularProgressIndicator());
        }
        else if (state is StateInitialConfiguracoes) {
          _devices = state.devices;
          _devices.forEach((device) {
            if (device.address == state.printerAddress)
              _printer = device;
          });
          _tipoEntrada = state.tipoEntrada;
          bloc.dispatch(InitialEvent());
        }
        else if (state is StateSuccess) {          
          Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context, true));
        }
        else if (state is StateError){
          Future.delayed(const Duration(seconds: 1), () => ConfirmationDialog.snackbar(context: context, mensagem: state.error, cor: Colors.red));          
          bloc.dispatch(InitialEvent()); 
        }

        return bodyWidget;       
      }  
    );
  }  

  Widget _renderInitial() {
    return ListView(children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 10),
        child: ListTile(
          leading: Icon(Icons.input),
          title: Text('Metodo de Entrada'),
          subtitle: 
          DropdownButton(
            hint: Text('Metodo de Entrada'),
            isExpanded: true,
            items: _tiposEntrada,
            onChanged: (value) => setState(() => _tipoEntrada = value),
            value: _tipoEntrada,
          ),
        ),
      ),

      Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 20),
        child: ListTile(
          leading: Icon(Icons.print),
          title: Text('Impressora'),
          subtitle: 
            DropdownButton(
              hint: Text('Selecione...'),
              isExpanded: true,
              items: _getDeviceItems(),
              onChanged: (value) => setState(() => _printer = value),
              value: _printer,
            ),
          trailing: FlatButton.icon(
            icon: Icon(MdiIcons.accessPoint),
            label: Text('Testar'),
            onPressed: () => _imprimirTesteImpressora()
          ),
        ),
      ),      

    ]);
  }

  void _imprimirTesteImpressora() async {
    await printerService.setBluetoothDevice(_printer)
    .catchError((error) {
      ConfirmationDialog.snackbar(
        context: _context,
        mensagem: '${error.toString()}',
        cor: Colors.red
      );
    });

    if (await printerService.isConnect()) {
      printerService.printText(msg: 'Teste impressora ${_printer.name}');
      printerService.feedLine();    
    }
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices == null || _devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('Nenhum disponível'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  } 

  Widget floatActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.save),
      label: Text('Salvar'),
      onPressed: () {
        bloc.dispatch(SaveConfiguracoes(_tipoEntrada, _printer?.address));
      },
    );
  }   
  
}