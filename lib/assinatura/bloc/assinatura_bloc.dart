import 'package:bloc/bloc.dart';
import 'package:smartparking_flutter2/model/subscription_model.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/services.dart';

import 'assinatura_event.dart';
import 'assinatura_state.dart';

import '../../service/subscription_service.dart';

class AssinaturaBloc extends Bloc<AssinaturaEvent, AssinaturaState> {

  @override
  void onTransition(Transition<AssinaturaEvent, AssinaturaState> transition) {
    print(transition.toString());
  }

  @override
  AssinaturaState get initialState => StateLoading();
  
  @override
  Stream<AssinaturaState> mapEventToState(AssinaturaEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoadInitial) {
        yield StateLoading();
        
        final bool available = await InAppPurchaseConnection.instance.isAvailable();        
        if (!available) {
          yield StateError('Erro de comunicação com a loja Google Play. Tente novamente');
        }
        else {
          Subscription subscriptionAtual = await SubscriptionService.getSubscriptionUsuarioLogado();
          List<Subscription> subscriptions = await SubscriptionService.getSubscriptionfromStore()
            .catchError((error) => throw('Erro de conexão com a loja de aplicativos'));
          yield StateLoadInitial(subscriptions, subscriptionAtual);          
        }
      }
      else if (event is ComprarAssinatura) {
        print('called ComprarAssinatura()');
        bool subscriptionComprado = await SubscriptionService.buySubscription(event.subscription);
        print('PASSOUUU ComprarAssinatura()');
        print('subscriptionComprado = ${subscriptionComprado.toString()}');
      }
    }
    on PlatformException catch (error) {
      print('PlatformException ${error.code}');
    }
    catch (error){
      yield StateError(error.toString());
    }
  }   

}