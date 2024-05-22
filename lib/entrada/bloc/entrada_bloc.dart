import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/validation_exception.dart';

import '../../service/sinesp_service.dart';
import 'entrada_event.dart';
import 'entrada_state.dart';
import '../../model/entrada_model.dart';
import '../../model/mensalista_model.dart';
import '../../service/entrada_service.dart';
import '../../service/mensalista_service.dart';

import '../../service/configuracoes_local_service.dart';
import '../../model/tipo_entrada_model.dart';

import '../../model/sinesp_model.dart';

class EntradaBloc extends Bloc<EntradaEvent, EntradaState> {

  static const placaRegex = r'[a-zA-Z]{3}[0-9]{4}|[a-zA-Z]{3}[0-9]{1}[a-zA-Z]{1}[0-9]{2}';

  @override
  void onTransition(Transition<EntradaEvent, EntradaState> transition) {
    print(transition.toString());
  }

  @override
  EntradaState get initialState => StateLoading();
  
  @override
  Stream<EntradaState> mapEventToState(EntradaEvent event) async* {
    try {

      if (event is InitialEvent) {
        yield StateInitial();
      }  
      else if (event is InitialEntrada) {
        yield StateLoading();       
        TipoEntrada tipoEntrada = await ConfiguracoesLocalService.getTipoEntrada(); 
        String entradaId = await EntradaService.adicionarEntradaId(); //obter id antes de inserir no db para gravar no nfc ou qrcode

        yield StateInitialEntrada(entradaId, tipoEntrada);
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
        else {
          yield StateModeloError();
        }
      }
      else if (event is AddEntrada) {
        yield StateLoading();
        
        if (!EntradaService.validarPlaca(event.entrada.placa)) throw ValidationException('Placa inválida'); 
        
        //verificar se já esta cadastrado
        QuerySnapshot query = await EntradaService.procurarPlaca(event.entrada.placa);
        if (query.documents.isNotEmpty) throw ValidationException('Placa já cadastrada');

        //verificar se é mensalista
        Mensalista mensalista = await MensalistaService.getMensalistaByPlaca(event.entrada.placa);
        bool isMensalista = (mensalista != null);        

        //verificar se está com o tipoEntradaId
        if (event.entrada.tipoEntrada == TipoEntrada.QRCODE_CARD) {
          if (event.entrada.tipoEntradaId.isEmpty) 
            throw ValidationException('QR Code não foi escaneado');

          if (await EntradaService.procurarTipoEntradaId(event.entrada.tipoEntradaId) != null)          
            throw ValidationException('QR Code já utilizado!');
        }          

        if (event.entrada.tipoEntrada == TipoEntrada.NFC_CARD && event.entrada.tipoEntradaId.isEmpty)
          throw ValidationException('Cartão NFC não foi gravado');

        Entrada entrada = event.entrada;
        entrada.dataLocal = DateTime.now();
        entrada.isMensalista = isMensalista;
        
        await EntradaService.adicionarEntrada(entrada);

        bool imprimir = event.imprimir ?? false;
        if (imprimir && entrada.tipoEntrada == TipoEntrada.BLUETOOTH_PRINTER)
          EntradaService.imprimirReciboEntrada(entrada);

        yield StateSuccess();
      }

      else if (event is FetchEntradasAberto) {
        yield StateLoading();
        List<Entrada> entradas = await EntradaService.getEntradasAbertas();
        yield StateFetchAbertos(entradas);
      }
      
      else if (event is SearchEntradasAberto) {
        //procura por PLACA ou codENTRADA
        yield StateLoading();
        List<Entrada> entradas = await EntradaService.getEntradasAbertas();
        List<Entrada> entradasSearch = entradas.where((entrada) {
          return entrada.placa.toLowerCase().contains(event.queryString.toLowerCase()); 
          //entrada.codEntrada.toString().contains(event.queryString);
        }).toList();
        yield StateFetchAbertos(entradasSearch);
      }   

    }
    on ValidationException catch(error) {
      yield StateError(error.message);
    }      
    catch (error) {
      yield StateError(error.toString());  
    }  
  }   

  

}