import 'package:equatable/equatable.dart';
import '../../model/login_model.dart';
import '../../model/convite_model.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class StateInitial extends LoginState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends LoginState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccessConfirmation extends LoginState {
  final String uid;
  final Convite convite;
  final LoginStatus loginStatus;
  StateSuccessConfirmation(this.uid, this.loginStatus, this.convite);
  @override
  String toString() => 'StateSuccessConfirmation ${loginStatus.toString()}';
}

class StateSuccessNewUser extends LoginState {
  final String asssinaturaId;
  StateSuccessNewUser(this.asssinaturaId);
  @override
  String toString() => 'StateSuccessNewUser';
}

class StateSuccessUserInvite extends LoginState {
  @override
  String toString() => 'StateSuccessUserInvite';
}

class StateError extends LoginState {
  final String error;
  StateError(this.error) : super([error]);
  @override
  String toString() => 'StateError $error';
}


