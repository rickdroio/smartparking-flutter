import 'package:equatable/equatable.dart';
import '../../model/sinesp_model.dart';
import '../../model/entrada_model.dart';
import '../../model/tipo_entrada_model.dart';

abstract class EntradaState extends Equatable {
  EntradaState([List props = const []]) : super(props);
}

class StateInitial extends EntradaState {
  @override
  String toString() => 'StateInitial';
}

class StateInitialEntrada extends EntradaState {
  final TipoEntrada tipoEntrada;
  final String entradaId;
  StateInitialEntrada(this.entradaId, this.tipoEntrada);
  @override
  String toString() => 'StateInitialEntrada';
}

class StateLoading extends EntradaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends EntradaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends EntradaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError';
}

class StateModeloLoading extends EntradaState {
  @override
  String toString() => 'StateLoadingModelo';
}

class StateModeloSuccess extends EntradaState {
  final Sinesp sinesp;
  StateModeloSuccess(this.sinesp) : super([sinesp]);

  @override
  String toString() => 'StateSearchSuccess';
}

class StateModeloError extends EntradaState {
  @override
  String toString() => 'StateModeloError';
}

class StateFetchAbertos extends EntradaState {
  final List<Entrada> entradas;
  StateFetchAbertos(this.entradas) : super([entradas]);

  @override
  String toString() => 'EntradaStateFetchAbertos, total ${entradas.length.toString()}';
}
