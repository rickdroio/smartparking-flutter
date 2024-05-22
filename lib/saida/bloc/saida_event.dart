import 'package:equatable/equatable.dart';
import '../../model/entrada_model.dart';

abstract class SaidaEvent extends Equatable {
  SaidaEvent([List props = const []]) : super(props);
}

class InitialEvent extends SaidaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class SearchEntradasAberto extends SaidaEvent {
  final String queryString;
  SearchEntradasAberto(this.queryString);
  @override
  String toString() => 'SearchEntradasAberto $queryString';
}

class CalcularSaida extends SaidaEvent {
  final String idEntrada;
  CalcularSaida(this.idEntrada);
  @override
  String toString() => 'CalcularSaida $idEntrada';
}

class UpdatePrecoSaida extends SaidaEvent {
  final String tabelaId;
  final String nomeTabela;
  final Entrada entrada;
  UpdatePrecoSaida(this.tabelaId, this.nomeTabela, this.entrada);
  @override
  String toString() => 'UpdatePrecoSaida $tabelaId';
}

class UpdateFormaPgto extends SaidaEvent {
  final String formaPgto;
  final Entrada entrada;
  UpdateFormaPgto(this.formaPgto, this.entrada);
  @override
  String toString() => 'UpdateFormaPgto';  
}

class FinalizarSaida extends SaidaEvent {
  final Entrada entrada;
  FinalizarSaida(this.entrada);
  @override
  String toString() => 'FinalizarSaida ${entrada.id}';
}

class InitSaidaManual extends SaidaEvent {
  @override
  String toString() => 'InitSaidaManual';
}

class SaidaProcurarTipoEntradaId extends SaidaEvent {
  final String tipoEntradaId;
  SaidaProcurarTipoEntradaId(this.tipoEntradaId);
  @override
  String toString() => 'SaidaProcurarTipoEntradaId';
}

class SaidaProcurarEntradaId extends SaidaEvent {
  final String id;
  SaidaProcurarEntradaId(this.id);
  @override
  String toString() => 'SaidaProcurarEntradaId';
}