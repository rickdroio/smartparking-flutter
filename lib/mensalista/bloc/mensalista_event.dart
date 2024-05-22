import 'package:equatable/equatable.dart';
import '../../model/mensalista_model.dart';

abstract class MensalistaEvent extends Equatable {
  MensalistaEvent([List props = const []]) : super(props);
}

class InitialEvent extends MensalistaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoadInitialData extends MensalistaEvent {
  @override
  String toString() => 'LoadInitialData';  
}

class LoadInitialItemData extends MensalistaEvent {
  final String id;
  LoadInitialItemData(this.id);
  @override
  String toString() => 'LoadInitialItemData';  
}

class SaveMensalista extends MensalistaEvent {
  final Mensalista mensalista;
  SaveMensalista(this.mensalista);
  @override
  String toString() => 'SaveEstacionamento';  
}

class SearchPlaca extends MensalistaEvent {
  final String placa;
  SearchPlaca(this.placa) : super([placa]);
  
  @override
  String toString() => 'SearchPlaca $placa';
}