import 'package:equatable/equatable.dart';
import '../../model/entrada_model.dart';

abstract class EntradaEvent extends Equatable {
  EntradaEvent([List props = const []]) : super(props);
}

class SearchPlaca extends EntradaEvent {
  final String placa;
  SearchPlaca(this.placa) : super([placa]);
  
  @override
  String toString() => 'SearchPlaca $placa';
}

class AddEntrada extends EntradaEvent {
  final Entrada entrada;
  final bool imprimir;
  AddEntrada(this.entrada, {this.imprimir});

  @override
  String toString() => 'AddEntrada';  
}

class InitialEvent extends EntradaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class InitialEntrada extends EntradaEvent {
  @override
  String toString() => 'InitialEntrada';  
}

class FetchEntradasAberto extends EntradaEvent {
  @override
  String toString() => 'FetchEntradasAberto';  
}

class SearchEntradasAberto extends EntradaEvent {
  final String queryString;
  SearchEntradasAberto(this.queryString);
  @override
  String toString() => 'SearchEntradasAberto $queryString';
}

class InitFinalizarEntrada extends EntradaEvent {
  final String idEntrada;
  InitFinalizarEntrada(this.idEntrada);
  @override
  String toString() => 'FinalizarEntrada $idEntrada';
}
