import 'package:equatable/equatable.dart';
import '../../model/caixa_item_model.dart';
import '../../model/caixa_model.dart';

abstract class CaixaEvent extends Equatable {
  CaixaEvent([List props = const []]) : super(props);
}

class InitialEvent extends CaixaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class GetCaixaAbertoEvent extends CaixaEvent {
  @override
  String toString() => 'GetCaixaAbertoEvent';  
}

class FinalizarCaixaEvent extends CaixaEvent {
  final Caixa caixa;
  final List<CaixaItem> itemsCaixa;  
  FinalizarCaixaEvent(this.caixa, this.itemsCaixa);
  @override
  String toString() => 'FinalizarCaixaEvent';  
}

class GetCaixasFechado extends CaixaEvent {
  @override
  String toString() => 'GetCaixasFechado';
}

class GetCaixaDetalhes extends CaixaEvent {
  final String id;
  GetCaixaDetalhes(this.id);
  @override
  String toString() => 'GetCaixaDetalhes';
}