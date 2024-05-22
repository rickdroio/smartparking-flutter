import 'package:bloc/bloc.dart';
import 'mensalista_event.dart';
import 'mensalista_state.dart';
import '../../service/mensalista_service.dart';
import '../../service/entrada_service.dart';
import '../../service/sinesp_service.dart';
import '../../model/mensalista_model.dart';
import '../../model/sinesp_model.dart';
import '../../shared/validators.dart';
import '../../service/subscription_service.dart';
import '../../model/subscription_model.dart';
import '../../shared/validation_exception.dart';

class MensalistaBloc extends Bloc<MensalistaEvent, MensalistaState> {

  @override
  void onTransition(Transition<MensalistaEvent, MensalistaState> transition) {
    print(transition.toString());
  }

  @override
  MensalistaState get initialState => StateInitial();
  
  @override
  Stream<MensalistaState> mapEventToState(MensalistaEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoadInitialData) {
        yield StateLoading();
        List<Mensalista> items = await MensalistaService.getMensalistas();
        yield StateInitialData(items);
      }
      else if (event is LoadInitialItemData) {
        yield StateLoading();
        Mensalista mensalista = await MensalistaService.getMensalista(event.id);
        yield StateInitialItemData(mensalista);
      }
      else if (event is SearchPlaca) {
        yield StateModeloLoading();
        final String placa = event.placa;

        if (EntradaService.validarPlaca(placa)) {
          Sinesp sinesp = await SinespService.consultarPlaca(placa);

          if (sinesp == null) {
            yield StateModeloError();
          } else {
            yield StateModeloSuccess(sinesp);
          }
        }
      }      
      else if (event is SaveMensalista) {
        yield StateLoading();
        
        Validators.notEmpty('Nome do mensalista', event.mensalista.nome);
        Validators.notEmpty('Placa', event.mensalista.placa);
        Validators.notEmpty('Modelo', event.mensalista.modelo);

        MensalistaService.adicionar(event.mensalista);
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