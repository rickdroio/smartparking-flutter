import 'package:equatable/equatable.dart';
import '../../model/tabela_model.dart';
import '../../model/tabela_item_model.dart';

abstract class TabelaState extends Equatable {
  TabelaState([List props = const []]) : super(props);
}

class StateInitial extends TabelaState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends TabelaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends TabelaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends TabelaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}

class StateSearchTabelas extends TabelaState {
  final List<Tabela> tabelas;  
  final String tabelaPadrao;
  StateSearchTabelas(this.tabelas, this.tabelaPadrao);
  @override
  String toString() => 'StateSearchTabelas = ${tabelas.length.toString()}';
}

class StateSearchTabelaItems extends TabelaState {
  final List<TabelaItem> items;
  StateSearchTabelaItems(this.items);
  @override
  String toString() => 'StateSearchTabelaItems';
}

class StateInitialTabelaData extends TabelaState {
  final Tabela tabela;
  StateInitialTabelaData(this.tabela);
  @override
  String toString() => 'StateInitialTabelaData';
}

class StateInitialTabelaItemData extends TabelaState {
  final TabelaItem item;
  StateInitialTabelaItemData(this.item);
  @override
  String toString() => 'StateInitialTabelaItemData';
}