import 'package:bloc/bloc.dart';

import 'caixa_event.dart';
import 'caixa_state.dart';

import '../../model/entrada_model.dart';
import '../../service/entrada_service.dart';

import '../../service/caixa_service.dart';
import '../../model/caixa_model.dart';
import '../../model/caixa_item_model.dart';

class CaixaBloc extends Bloc<CaixaEvent, CaixaState> {

  @override
  void onTransition(Transition<CaixaEvent, CaixaState> transition) {
    print(transition.toString());
  }

  @override
  CaixaState get initialState => StateLoading();
  
  @override
  Stream<CaixaState> mapEventToState(CaixaEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }            
      else if (event is GetCaixaAbertoEvent) {
        yield StateLoading();
        Caixa caixa = await CaixaService.getCaixaAberto(createIfNotExist: false);
        
        if (caixa == null) {
          yield StateNenhumCaixa('Não existe caixa aberto!');
        }
        else
        {
          yield StateLoading();
          List<Entrada> entradas = await EntradaService.getEntradasCaixa(caixa.id);

          //criar itens com todas as formasPgto
          List<CaixaItem> items = List<CaixaItem>();
          formasPgto.forEach((f) => items.add(CaixaItem(formaPgto: f, valorTotal: 0.0, caixaId: caixa.id)));
          //items.add(CaixaItem(formaPgto: 'Mensalista', valorTotal: 0.0, caixaId: caixa.id));

          double total = 0.0;
          entradas.forEach((entrada){
            if (!entrada.isMensalista) { //desconsiderar MENSALISTA
              int formaPgtoIndex = items.indexWhere((i) {
                return i.formaPgto == entrada.formaPgto;
              });
              
              items[formaPgtoIndex].valorTotal += entrada.valorTotal;
              total += entrada.valorTotal;
            }
          });

          caixa.dataFechamento = DateTime.now();
          caixa.valorTotal = total;

          yield StateGetCaixaAberto(caixa, items, entradas);
        }
      }
      else if (event is FinalizarCaixaEvent) {
        yield StateLoading();

        CaixaService.finalizarCaixa(event.caixa, event.itemsCaixa);

        yield StateSuccess();
      }

      else if (event is GetCaixasFechado) {
        yield StateLoading();
        List<Caixa> caixas = await CaixaService.getCaixasFechados();
        yield StateGetCaixasFechado(caixas);
      }

      else if (event is GetCaixaDetalhes) {
        yield StateLoading();
        List<Entrada> entradas = await EntradaService.getEntradasCaixa(event.id);
        yield StateGetCaixaDetalhes(entradas);
      }
     
    }
    catch (error){
      yield StateError(error.toString());
    }

  }   

}