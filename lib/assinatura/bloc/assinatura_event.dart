import 'package:equatable/equatable.dart';
import '../../model/subscription_model.dart';

abstract class AssinaturaEvent extends Equatable {
  AssinaturaEvent([List props = const []]) : super(props);
}

class InitialEvent extends AssinaturaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoadInitial extends AssinaturaEvent {
  @override
  String toString() => 'InitialEvent';  
}

class ComprarAssinatura extends AssinaturaEvent {
  final Subscription subscription;
  ComprarAssinatura(this.subscription);
  @override
  String toString() => 'ComprarAssinatura';  
}
