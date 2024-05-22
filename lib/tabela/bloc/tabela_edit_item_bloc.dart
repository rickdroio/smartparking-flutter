import 'package:bloc/bloc.dart';
import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';
import 'tabela_event.dart';
import 'tabela_state.dart';
import '../../model/tabela_item_model.dart';
import '../../service/tabela_service.dart';

class TabelaEditItemBloc extends Bloc<TabelaEvent, TabelaState> {

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
      else if (event is LoadInitialItemData) {
        yield StateLoading();
        TabelaItem item = await TabelaService.getTabelaItem(event.tabelaId, event.id);
        yield StateInitialTabelaItemData(item);
      }
      else if (event is SaveTabelaItem){
        yield StateLoading();
        try {
          await formValidationTabela(event.item);
          TabelaService.adicionarItemTabela(event.item);
          yield StateSuccess();    
        } 
        on ValidationException catch(error) {
          yield StateError(error.message);
        }
        catch(error) {
          yield StateError(error.toString());
        }
      }   
      else if (event is DeleteTabelaItem) {        
        yield StateLoading();
        TabelaService.deleteItemTabela(event.item);
        yield StateSuccess();
      }
    }
    catch (error) {
      yield StateError(error.toString());  
    }  
  }

  Future formValidationTabela(TabelaItem item) async {
    Validators.greaterThanZeroInt('Período', item.periodo);
    Validators.greaterEqualThanZeroDouble('Preço', item.preco);
  }

}