import 'package:bloc/bloc.dart';
import 'estacionamento_event.dart';
import 'estacionamento_state.dart';
import '../../service/estacionamento_service.dart';
import '../../model/estacionamento.dart';
import '../../shared/validators.dart';
import '../../service/subscription_service.dart';
import '../../model/subscription_model.dart';
import '../../shared/validation_exception.dart';
import '../../model/usuario_model.dart';
import '../../service/usuario_service.dart';

class EstacionamentoBloc extends Bloc<EstacionamentoEvent, EstacionamentoState> {

  @override
  void onTransition(Transition<EstacionamentoEvent, EstacionamentoState> transition) {
    print(transition.toString());
  }

  @override
  EstacionamentoState get initialState => StateInitial();
  
  @override
  Stream<EstacionamentoState> mapEventToState(EstacionamentoEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoadInitialData) {
        yield StateLoading();
        List<Estacionamento> items = await EstacionamentoService.getEstacionamentos();
        yield StateInitialData(items);
      }
      else if (event is LoadInitialItemData) {
        yield StateLoading();
        Estacionamento estacionamento = await EstacionamentoService.getEstacionamento(event.estacionamentoId);
        yield StateInitialItemData(estacionamento);
      }
      else if (event is SaveEstacionamento) {
        yield StateLoading();
        
        Validators.notEmpty('Nome do estacionamento', event.estacionamento.nome);
        Validators.notEmpty('Endereço do estacionamento', event.estacionamento.endereco);

        EstacionamentoService.adicionarEstacionamento(event.estacionamento);
        yield StateSuccess();
      }
      else if (event is NewEstacionamento) {
        yield StateLoading();

        List<Estacionamento> estacionamentos = await EstacionamentoService.getEstacionamentosUsuarioLogado();
        Subscription subscription = await SubscriptionService.getSubscriptionUsuarioLogado();

        if (estacionamentos.length >= subscription.qtdeEstacionamentos) 
          yield StateError('Limite de estacionamentos atingido (máx ${subscription.qtdeEstacionamentos.toString()}), verifique o menu de assinaturas');
        else
          yield StateSuccessNewEstacionamento();
      }
      else if (event is LoadInitialUsersData) {
        yield StateLoading();
        Estacionamento estacionamento = await EstacionamentoService.getEstacionamento(event.estacionamentoId);

        List<Usuario> usuarios = await UsuarioService.getUsuarios();
        if (usuarios == null) usuarios = List<Usuario>();

        yield StateInitialUserData(estacionamento, usuarios);
      }
      else if (event is SaveUsersData) {
        yield StateLoading();
        EstacionamentoService.setUsuarioEstacionamento(event.estacionamentoId, event.usuarios);
        yield StateSuccess();
      }
     
    }
    on ValidationException catch(error) {
      print('ValidationException ${error.message.toString()}');
      yield StateError(error.message);
    }        
    catch (error){
      yield StateError(error.toString());
    }

  }   

}