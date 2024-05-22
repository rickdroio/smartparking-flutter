import 'package:equatable/equatable.dart';
import '../../model/usuario_model.dart';

abstract class UsuarioEvent extends Equatable {
  UsuarioEvent([List props = const []]) : super(props);
}

class InitialEvent extends UsuarioEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoadInitialData extends UsuarioEvent {
  @override
  String toString() => 'LoadInitialData';  
}

class SaveUser extends UsuarioEvent {
  final Usuario usuario;
  SaveUser(this.usuario);
  @override
  String toString() => 'SaveUser';  
}

class LoadConviteUser extends UsuarioEvent {
  @override
  String toString() => 'LoadConviteUser';    
}

class ConviteUser extends UsuarioEvent {
  final String nome;
  final String telefone;
  final String estacionamentoId;
  ConviteUser(this.nome, this.telefone, this.estacionamentoId);
  @override
  String toString() => 'ConviteUser';  
}
