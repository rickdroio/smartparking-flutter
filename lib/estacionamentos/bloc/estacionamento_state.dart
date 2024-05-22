import 'package:equatable/equatable.dart';
import '../../model/estacionamento.dart';
import '../../model/usuario_model.dart';

abstract class EstacionamentoState extends Equatable {
  EstacionamentoState([List props = const []]) : super(props);
}

class StateInitial extends EstacionamentoState {
  @override
  String toString() => 'StateInitial';
}

class StateInitialData extends EstacionamentoState {
  final List<Estacionamento> items;
  StateInitialData(this.items);
  @override
  String toString() => 'StateInitialData ${items.length.toString()}';
}

class StateInitialItemData extends EstacionamentoState {
  final Estacionamento estacionamento;
  StateInitialItemData(this.estacionamento);
  @override
  String toString() => 'StateInitialItemData';
}

class StateLoading extends EstacionamentoState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends EstacionamentoState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends EstacionamentoState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateSuccessNewEstacionamento extends EstacionamentoState {
  @override
  String toString() => 'StateSuccessNewEstacionamento';
}

class StateInitialUserData extends EstacionamentoState {
  final Estacionamento estacionamento;
  final List<Usuario> usuarios;
  StateInitialUserData(this.estacionamento, this.usuarios);
  @override
  String toString() => 'StateInitialUserData';
}