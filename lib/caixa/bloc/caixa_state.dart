import 'package:equatable/equatable.dart';
import '../../model/caixa_item_model.dart';
import '../../model/caixa_model.dart';
import '../../model/entrada_model.dart';

abstract class CaixaState extends Equatable {
  CaixaState([List props = const []]) : super(props);
}

class StateInitial extends CaixaState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends CaixaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends CaixaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends CaixaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateNenhumCaixa extends CaixaState {
  final String error;
  StateNenhumCaixa(this.error) : super([error]);

  @override
  String toString() => 'StateNenhumCaixa $error';
}

class StateGetCaixaAberto extends CaixaState {
  final Caixa caixa;
  final List<CaixaItem> itemsCaixa;
  final List<Entrada> entradas;
  StateGetCaixaAberto(this.caixa, this.itemsCaixa, this.entradas) : super([caixa, itemsCaixa]);

  @override
  String toString() => 'StateGetCaixaAberto';
}

class StateGetCaixasFechado extends CaixaState {
  final List<Caixa> caixas;
  StateGetCaixasFechado(this.caixas) : super([caixas]);

  @override
  String toString() => 'StateGetCaixasFechado';
}

class StateGetCaixaDetalhes extends CaixaState {
  final List<Entrada> entradas;
  StateGetCaixaDetalhes(this.entradas);

  @override
  String toString() => 'StateGetCaixaDetalhes';
}


