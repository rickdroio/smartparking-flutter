import 'package:bloc/bloc.dart';
import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';
import 'tabela_event.dart';
import 'tabela_state.dart';
import '../../model/tabela_model.dart';
import '../../service/tabela_service.dart';

class TabelaEditBloc extends Bloc<TabelaEvent, TabelaState> {

  @override
  void onTransition(Transition<TabelaEvent, TabelaState> transition) {
    print(transition.toString());
  }

  @override
  TabelaState get initialState => StateInitial();
  
  @override
  Stream<TabelaState> mapEventToState(TabelaEvent event) async* {
    try {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoadInitialData) {
        yield StateLoading();
        Tabela tabela = await TabelaService.getTabela(event.id);
        yield StateInitialTabelaData(tabela);       
      }
      else if (event is SaveTabela){
        yield StateLoading();
        try {
          Validators.minLength('Nome Tabela', 5, event.tabela.nomeTabela);

          TabelaService.adicionarTabela(event.tabela);          
          yield StateSuccess();
        } 
        on ValidationException catch(error) {
          yield StateError(error.message);
        }
        catch(error) {
          yield StateError(error.toString());
        }
      }      
    }
    catch (error) {
      yield StateError(error.toString());  
    }  
  }

}