import 'package:equatable/equatable.dart';
import 'package:smartparking_flutter2/model/tipo_entrada_model.dart';
import '../../model/entrada_model.dart';
import '../../model/tabela_model.dart';

abstract class SaidaState extends Equatable {
  SaidaState([List props = const []]) : super(props);
}

class StateInitial extends SaidaState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends SaidaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends SaidaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends SaidaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateErrorCancel extends SaidaState {
  final String error;
  StateErrorCancel(this.error) : super([error]);
  @override
  String toString() => 'StateErrorCancel $error';
}

class StateSearchEntradasAberto extends SaidaState {
  final List<Entrada> entradas;
  StateSearchEntradasAberto(this.entradas) : super([entradas]);

  @override
  String toString() => 'StateSearchEntradasAberto, total ${entradas.length.toString()}';
}

class StateCalcularSaida extends SaidaState {
  final Entrada entrada;
  final List<Tabela> tabelas;
  StateCalcularSaida(this.entrada, this.tabelas) : super([entrada]);

  @override
  String toString() => 'StateCalcularSaida';
}

class StateUpdatePrecoSaida extends SaidaState {
  final Entrada entrada;
  StateUpdatePrecoSaida(this.entrada) : super([entrada]);

  @override
  String toString() => 'StateCalcularSaida';
}

class StateSaidaManualSuccess extends SaidaState {
  final String idEntrada;
  StateSaidaManualSuccess(this.idEntrada) : super([idEntrada]);

  @override
  String toString() => 'StateSaidaManualSuccess $idEntrada';
}

class StateInitSaidaManual extends SaidaState {
  final TipoEntrada tipoEntrada;
  StateInitSaidaManual(this.tipoEntrada) : super([tipoEntrada]);

  @override
  String toString() => 'StateInitSaidaManual ${tipoEntrada.toString()}';
}
