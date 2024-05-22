import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'package:package_info/package_info.dart';

import '../../service/usuario_service.dart';
import '../../service/estacionamento_service.dart';
import '../../service/error_service.dart';
import '../../service/assinatura_service.dart';
import '../../service/subscription_service.dart';

import '../../model/assinatura_model.dart';
import '../../model/usuario_model.dart';
import '../../model/estacionamento.dart';
import '../../model/subscription_model.dart';
import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {

  @override
  void onTransition(Transition<DashboardEvent, DashboardState> transition) {
    print(transition.toString());
  }

  @override
  DashboardState get initialState => StateInitial();
  
  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateLoading();
      }

      else if (event is LoadInitialData) {
        yield StateLoading();

        PackageInfo packageInfo = await PackageInfo.fromPlatform(); //packageInfo.version
        Stream<DocumentSnapshot> estacionamentoStream = await EstacionamentoService.getEstacionamentoStreamUsuarioLogado();
        Usuario usuario = await UsuarioService.getUsuarioLogado();
        Estacionamento estacionamento = await EstacionamentoService.getEstacionamentoUsuarioLogado();
        Subscription subscription = await SubscriptionService.getSubscriptionUsuarioLogado();
        Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();

        yield StateInitialData(
          appVersion: packageInfo.version,
          estacionamentoStream: estacionamentoStream,
          usuario: usuario,
          estacionamento: estacionamento,
          subscription: subscription,
          assinatura: assinatura
        );
      }      

    }
    on ValidationException catch(error) {
      print('ValidationException ${error.message.toString()}');
      yield StateError(error.message);
    }    
    catch (error) {
      print('error ${error.message.toString()}');
      yield StateError(ErrorService.translate(error));
    }
  }   



}