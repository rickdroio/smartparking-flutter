import 'package:bloc/bloc.dart';
import 'package:smartparking_flutter2/model/tipo_entrada_model.dart';
import 'saida_event.dart';
import 'saida_state.dart';
import '../../model/entrada_model.dart';
import '../../model/tabela_model.dart';
import '../../model/caixa_model.dart';
import '../../service/entrada_service.dart';
import '../../service/tabela_service.dart';
import '../../service/caixa_service.dart';
import '../../service/configuracoes_local_service.dart';

import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';

class SaidaBloc extends Bloc<SaidaEvent, SaidaState> {

  @override
  void onTransition(Transition<SaidaEvent, SaidaState> transition) {
    print(transition.toString());
  }

  @override
  SaidaState get initialState => StateLoading();
  
  @override
  Stream<SaidaState> mapEventToState(SaidaEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }       
      else if (event is SearchEntradasAberto) {
        //TODO - possivel reducao de custo firebase
        yield StateLoading();
        List<Entrada> entradas = await EntradaService.getEntradasAbertas();
        List<Entrada> entradasSearch = entradas.where((entrada) {
          return entrada.placa.toLowerCase().contains(event.queryString.toLowerCase()); 
          //entrada.codEntrada.toString().contains(event.queryString);
        }).toList();
        yield StateSearchEntradasAberto(entradasSearch);
      }
      else if (event is CalcularSaida) {
        yield StateLoading();
        
        List<Tabela> tabelas = await TabelaService.getTabelasAtivas();
        if (tabelas.length == 0) {
          yield StateErrorCancel('Nenhuma tabela de preço cadastrada');
        }
        else {
          //Tabela tabela = tabelas.first; //pega primeira tabela de acordo com a ordem para o calculo inicial
          //print('tabela id = ${tabela.id}');        

          Entrada entrada = await EntradaService.getEntrada(event.idEntrada);
          entrada.dataSaidaLocal = DateTime.now();
          print('getEntrada ${entrada.id}');

          Duration difference = entrada.dataSaidaLocal.difference(entrada.dataLocal);
          entrada.tempoTotal = difference.inMinutes;
          print('tempo total = ${entrada.tempoTotal}');

          Caixa caixa = await CaixaService.getCaixaAberto(createIfNotExist: true);
          entrada.caixaId = caixa.id;
          print('caixa id = ${entrada.caixaId}');

          print('isMensalista = ${entrada.isMensalista.toString()}');
          entrada.valorTotal = 0;
          if (entrada.isMensalista) 
            entrada.valorTotal = 0;
          else
            entrada.valorTotal = null; //para mostrar "escolha a tabela de preço no UI"

          yield StateCalcularSaida(entrada, tabelas);
        }
      }
      else if (event is UpdatePrecoSaida){
        Entrada entrada = event.entrada;
        double total = await TabelaService.calcularPrecoSaida(event.tabelaId, entrada.tempoTotal);
        
        entrada.tabelaId = event.tabelaId;
        entrada.nomeTabela = event.nomeTabela;
        entrada.valorTotal = total;
        yield StateUpdatePrecoSaida(entrada); 
      }
      else if (event is UpdateFormaPgto){        
        Entrada entrada = event.entrada;
        entrada.formaPgto = event.formaPgto;
        yield StateUpdatePrecoSaida(entrada); 
      }      
      else if (event is FinalizarSaida) {
        yield StateLoading();
        
        if (!event.entrada.isMensalista){
          Validators.notEmpty('Tabela de preço', event.entrada.tabelaId);
          Validators.notEmpty('Forma de pagamento', event.entrada.formaPgto);
        }

        EntradaService.finalizarSaida(event.entrada);
        yield StateSuccess();
      }

      else if (event is SaidaProcurarTipoEntradaId) {
        yield StateLoading();
        Entrada entrada = await EntradaService.procurarTipoEntradaId(event.tipoEntradaId);
        if (entrada != null) {
          yield StateSaidaManualSuccess(entrada.id);
        }
        else {
          yield StateError('Entrada não localizada');
        }     
      }

      else if (event is SaidaProcurarEntradaId) {
        yield StateLoading();
        Entrada entrada = await EntradaService.getEntrada(event.id);
        if (entrada != null) {
          yield StateSaidaManualSuccess(entrada.id);
        }
        else {
          yield StateError('Entrada não localizada');
        }     
      }


      else if (event is InitSaidaManual) {
        yield StateLoading();
        TipoEntrada tipoEntrada = await ConfiguracoesLocalService.getTipoEntrada();
        yield StateInitSaidaManual(tipoEntrada);
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