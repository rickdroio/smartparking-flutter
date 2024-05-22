import 'package:bloc/bloc.dart';
import 'tabela_event.dart';
import 'tabela_state.dart';
import '../../model/tabela_model.dart';
import '../../model/tabela_item_model.dart';
import '../../service/tabela_service.dart';

class TabelaBloc extends Bloc<TabelaEvent, TabelaState> {

  @override
  void onTransition(Transition<TabelaEvent, TabelaState> transition) {
    print(transition.toString());
  }

  @override
  TabelaState get initialState => StateLoading();
  
  @override
  Stream<TabelaState> mapEventToState(TabelaEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is SearchTabelas) {
        yield StateLoading();
        List<Tabela> tabelas = await TabelaService.getTabelas();
               
        String tabelaPadrao;
        tabelas.forEach((tabela) {
          if (tabela.tabelaPadrao ?? false)
            tabelaPadrao = tabela.id;
        });

        yield StateSearchTabelas(tabelas, tabelaPadrao);
      }
      else if (event is SearchTabelaItems) {
        yield StateLoading();
        List<TabelaItem> items = await TabelaService.getTabelaItems(event.tabelaId);
        yield StateSearchTabelaItems(items);
      }

      else if (event is SetTabelaPrecoPadrao) {
        yield StateLoading();
        TabelaService.setTabelaPadrao(event.id);
        yield StateInitial();
      }
     
    }
    catch (error){
      yield StateError(error.toString());
    }

  }   

}