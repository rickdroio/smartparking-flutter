import 'package:equatable/equatable.dart';
import '../../model/estacionamento.dart';
import '../../model/usuario_model.dart';

abstract class EstacionamentoEvent extends Equatable {
  EstacionamentoEvent([List props = const []]) : super(props);
}

class InitialEvent extends EstacionamentoEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoadInitialData extends EstacionamentoEvent {
  @override
  String toString() => 'LoadInitialData';  
}

class LoadInitialItemData extends EstacionamentoEvent {
  final String estacionamentoId;
  LoadInitialItemData(this.estacionamentoId);
  @override
  String toString() => 'LoadInitialItemData';  
}

class SaveEstacionamento extends EstacionamentoEvent {
  final Estacionamento estacionamento;
  SaveEstacionamento(this.estacionamento);
  @override
  String toString() => 'SaveEstacionamento';  
}

class NewEstacionamento extends EstacionamentoEvent {
  @override
  String toString() => 'NewEstacionamento';  
}

class LoadInitialUsersData extends EstacionamentoEvent {
  final String estacionamentoId;
  LoadInitialUsersData(this.estacionamentoId);
  @override
  String toString() => 'LoadInitialUsersData';  
}

class SaveUsersData extends EstacionamentoEvent {
  final String estacionamentoId;
  final List<Usuario> usuarios;
  SaveUsersData(this.estacionamentoId, this.usuarios);
  @override
  String toString() => 'SaveUsersData';  
}