import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/usuario_model.dart';
import '../../model/estacionamento.dart';
import '../../model/subscription_model.dart';
import '../../model/assinatura_model.dart';

abstract class DashboardState extends Equatable {
  DashboardState([List props = const []]) : super(props);
}

class StateInitial extends DashboardState {
  @override
  String toString() => 'StateInitial';
}

class StateLoading extends DashboardState {
  @override
  String toString() => 'StateLoading';
}

class StateError extends DashboardState {
  final String error;
  StateError(this.error) : super([error]);
  @override
  String toString() => 'StateError $error';
}

class StateInitialData extends DashboardState {
  final Stream<DocumentSnapshot> estacionamentoStream;
  final String appVersion;
  final Usuario usuario;
  final Estacionamento estacionamento;
  final Subscription subscription;
  final Assinatura assinatura;

  StateInitialData({this.estacionamentoStream, this.appVersion, this.usuario, this.estacionamento, this.subscription, this.assinatura});

  @override
  String toString() => 'StateInitialData';
}
