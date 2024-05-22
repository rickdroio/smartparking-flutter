import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/estacionamento.dart';
import '../../model/usuario_model.dart';

abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class InitialEvent extends LoginEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoginError extends LoginEvent {
  final String error;
  LoginError(this.error);
  @override
  String toString() => 'LoginError';  
}

class UserPhoneLogin extends LoginEvent {
  final String phone;
  final PhoneCodeSent codeSent;
  final PhoneVerificationFailed verificationFailed;  
  UserPhoneLogin(this.phone, this.codeSent, this.verificationFailed);
  @override
  String toString() => 'UserPhoneLogin';
}

class UserPhoneConfirmation extends LoginEvent {
  final String telefone;
  final String verificationId;
  final String smsCode;
  UserPhoneConfirmation(this.telefone, this.verificationId, this.smsCode);
  @override
  String toString() => 'UserPhoneConfirmation';  
}

class UserNew extends LoginEvent {
  final Estacionamento estacionamento;
  final Usuario usuario;
  final String promo;
  UserNew(this.estacionamento, this.usuario, this.promo);
  @override
  String toString() => 'UserNew';  
}

