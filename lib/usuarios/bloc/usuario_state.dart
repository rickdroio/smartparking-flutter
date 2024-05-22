import 'package:equatable/equatable.dart';
import 'package:smartparking_flutter2/model/estacionamento.dart';
import '../../model/usuario_model.dart';
import '../../model/convite_model.dart';

abstract class UsuarioState extends Equatable {
  UsuarioState([List props = const []]) : super(props);
}

class StateInitial extends UsuarioState {
  @override
  String toString() => 'StateInitial';
}

class StateInitialData extends UsuarioState {
  final List<Usuario> items;
  final List<Convite> convites;
  StateInitialData(this.items, this.convites);
  @override
  String toString() => 'StateInitialData ${items.length.toString()}';
}

class StateInitialDataConvite extends UsuarioState {
  final List<Estacionamento> estacionamento;
  StateInitialDataConvite(this.estacionamento);
  @override
  String toString() => 'StateInitialDataConvite';
}

class StateLoading extends UsuarioState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends UsuarioState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends UsuarioState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}