import 'package:bloc/bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../shared/validation_exception.dart';

import 'configuracoes_local_event.dart';
import 'configuracoes_local_state.dart';

import '../../service/printer_service.dart';
import '../../service/nfc_service.dart';
import '../../service/configuracoes_local_service.dart';
import '../../model/tipo_entrada_model.dart';

class ConfiguracoesLocalBloc extends Bloc<ConfiguracoesLocalEvent, ConfiguracoesLocalState> {

  @override
  void onTransition(Transition<ConfiguracoesLocalEvent, ConfiguracoesLocalState> transition) {
    print(transition.toString());
  }

  @override
  ConfiguracoesLocalState get initialState => StateLoading();
  
  @override
  Stream<ConfiguracoesLocalState> mapEventToState(ConfiguracoesLocalEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is InitConfiguracoes) {  
        yield (StateLoading()); 
        TipoEntrada tipoEntrada = await ConfiguracoesLocalService.getTipoEntrada();
        String printerAddress = await ConfiguracoesLocalService.getPrinter();
        List<BluetoothDevice> devices = await PrinterService.getBluetoothDevices();
        yield StateInitialConfiguracoes(devices, printerAddress, tipoEntrada);
      } 
      else if (event is SaveConfiguracoes) {  
        yield (StateLoading());      

        if (event.tipoEntrada == TipoEntrada.NFC_CARD) {
          bool supportNFC = await NfcService.supportsNFC();
          if (!supportNFC) {
            throw ValidationException('Dispositivo não suporta NFC');
          }
        }

        ConfiguracoesLocalService.saveLocalSetting(event.printerAddress, event.tipoEntrada);
        yield StateSuccess();        
      }
    }
    on ValidationException catch(error) {
      yield StateError(error.message);
    }    
    catch (error){
      yield StateError(error.toString());
    }
  }

}