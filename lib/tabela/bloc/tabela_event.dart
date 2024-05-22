import 'package:equatable/equatable.dart';
import '../../model/tabela_model.dart';
import '../../model/tabela_item_model.dart';

abstract class TabelaEvent extends Equatable {
  TabelaEvent([List props = const []]) : super(props);
}

class InitialEvent extends TabelaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class SearchTabelas extends TabelaEvent {
  @override
  String toString() => 'SearchTabelas';  
}

class SearchTabelaItems extends TabelaEvent {
  final String tabelaId;
  SearchTabelaItems(this.tabelaId);
  @override
  String toString() => 'SearchTabelaItems ${tabelaId.toString()}';  
}

class LoadInitialData extends TabelaEvent {
  final String id;
  LoadInitialData(this.id);
  @override
  String toString() => 'LoadInitialData $id';  
}

class SaveTabela extends TabelaEvent {
  final Tabela tabela;
  SaveTabela(this.tabela);
  @override
  String toString() => 'SaveTabela'; 
}

class LoadInitialItemData extends TabelaEvent {
  final String id;
  final String tabelaId;
  LoadInitialItemData(this.tabelaId, this.id);
  @override
  String toString() => 'LoadInitialItemData $id';  
}

class SaveTabelaItem extends TabelaEvent {
  final TabelaItem item;
  SaveTabelaItem(this.item);
  @override
  String toString() => 'SaveTabelaItem'; 
}

class DeleteTabelaItem extends TabelaEvent {
  final TabelaItem item;
  DeleteTabelaItem(this.item);
  @override
  String toString() => 'DeleteTabelaItem'; 
}

class SetTabelaPrecoPadrao extends TabelaEvent {
  final String id;
  SetTabelaPrecoPadrao(this.id);
  @override
  String toString() => 'SetTabelaPrecoPadrao $id';  
}

