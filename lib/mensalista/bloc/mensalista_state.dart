import 'package:equatable/equatable.dart';
import '../../model/mensalista_model.dart';
import '../../model/sinesp_model.dart';

abstract class MensalistaState extends Equatable {
  MensalistaState([List props = const []]) : super(props);
}

class StateInitial extends MensalistaState {
  @override
  String toString() => 'StateInitial';
}

class StateInitialData extends MensalistaState {
  final List<Mensalista> items;
  StateInitialData(this.items);
  @override
  String toString() => 'StateInitialData ${items.length.toString()}';
}

class StateInitialItemData extends MensalistaState {
  final Mensalista mensalista;
  StateInitialItemData(this.mensalista);
  @override
  String toString() => 'StateInitialItemData';
}

class StateLoading extends MensalistaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends MensalistaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends MensalistaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateSuccessNewEstacionamento extends MensalistaState {
  @override
  String toString() => 'StateSuccessNewEstacionamento';
}

class StateModeloLoading extends MensalistaState {
  @override
  String toString() => 'StateLoadingModelo';
}

class StateModeloSuccess extends MensalistaState {
  final Sinesp sinesp;
  StateModeloSuccess(this.sinesp) : super([sinesp]);

  @override
  String toString() => 'StateSearchSuccess';
}

class StateModeloError extends MensalistaState {
  @override
  String toString() => 'StateModeloError';
}