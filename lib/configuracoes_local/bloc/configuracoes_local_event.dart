import 'package:equatable/equatable.dart';
import 'package:smartparking_flutter2/model/tipo_entrada_model.dart';

abstract class ConfiguracoesLocalEvent extends Equatable {
  ConfiguracoesLocalEvent([List props = const []]) : super(props);
}

class InitialEvent extends ConfiguracoesLocalEvent {
  @override
  String toString() => 'InitialEvent';  
}

class InitConfiguracoes extends ConfiguracoesLocalEvent {
  @override
  String toString() => 'InitConfiguracoes';  
}

class SaveConfiguracoes extends ConfiguracoesLocalEvent {
  final TipoEntrada tipoEntrada;
  final String printerAddress;
  SaveConfiguracoes(this.tipoEntrada, this.printerAddress);
  @override
  String toString() => 'SavePrefsPrinter';  
}