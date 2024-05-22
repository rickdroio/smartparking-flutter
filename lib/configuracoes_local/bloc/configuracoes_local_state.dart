import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../model/tipo_entrada_model.dart';

abstract class ConfiguracoesLocalState extends Equatable {
  ConfiguracoesLocalState([List props = const []]) : super(props);
}

class StateInitial extends ConfiguracoesLocalState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends ConfiguracoesLocalState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends ConfiguracoesLocalState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends ConfiguracoesLocalState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateInitialConfiguracoes extends ConfiguracoesLocalState {
  final List<BluetoothDevice> devices;
  final String printerAddress;
  final TipoEntrada tipoEntrada;
  StateInitialConfiguracoes(this.devices, this.printerAddress, this.tipoEntrada);

  @override
  String toString() => 'StateInitialConfiguracoes = ${devices.length.toString()}';
}