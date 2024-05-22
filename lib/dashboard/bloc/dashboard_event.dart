import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  DashboardEvent([List props = const []]) : super(props);
}

class InitialEvent extends DashboardEvent {
  @override
  String toString() => 'InitialEvent';  
}

class LoadInitialData extends DashboardEvent {
  @override
  String toString() => 'LoadInitialData';  
}