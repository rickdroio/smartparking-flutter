import 'package:equatable/equatable.dart';
import '../../model/subscription_model.dart';

abstract class AssinaturaState extends Equatable {
  AssinaturaState([List props = const []]) : super(props);
}

class StateInitial extends AssinaturaState {
  @override
  String toString() => 'StateInitial';
}

class StateLoadInitial extends AssinaturaState {
  final List<Subscription> subscriptions;
  final Subscription subscriptionAtual;
  StateLoadInitial(this.subscriptions, this.subscriptionAtual);
  @override
  String toString() => 'StateLoadInitial';
}

class StateLoading extends AssinaturaState {
  @override
  String toString() => 'StateLoading';
}

class StateSuccess extends AssinaturaState {
  @override
  String toString() => 'StateSuccess';
}

class StateError extends AssinaturaState {
  final String error;
  StateError(this.error) : super([error]);

  @override
  String toString() => 'StateError $error';
}