import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:smartparking_flutter2/service/assinatura_service.dart';

import 'usuario_event.dart';
import 'usuario_state.dart';
import '../../service/usuario_service.dart';
import '../../service/estacionamento_service.dart';
import '../../model/usuario_model.dart';
import '../../model/assinatura_model.dart';
import '../../model/estacionamento.dart';

import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';

import '../../service/convite_service.dart';
import '../../model/convite_model.dart';


class UsuarioBloc extends Bloc<UsuarioEvent, UsuarioState> {

  @override
  void onTransition(Transition<UsuarioEvent, UsuarioState> transition) {
    print(transition.toString());
  }

  @override
  UsuarioState get initialState => StateLoading();
  
  @override
  Stream<UsuarioState> mapEventToState(UsuarioEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoadInitialData) {
        yield StateLoading();
        List<Usuario> items = await UsuarioService.getUsuarios();        
        for (var i = 0; i < items.length; i++) {
          List<Estacionamento> estacionamentos = await EstacionamentoService.getEstacionamentosUsuario(items[i].id);
          items[i].estacionamentosObject  = estacionamentos;
        }
        List<Convite> convites = await ConviteService.getConvites();
        yield StateInitialData(items, convites);
      }
      else if (event is SaveUser) {  
        UsuarioService.editUsuario(event.usuario);
        yield StateInitial();
      }
      else if (event is ConviteUser) {
        yield StateLoading();
        
        Validators.notEmpty('Nome', event.nome);
        Validators.notEmpty('Estacionamento', event.estacionamentoId);
        Validators.phonePattern('Telefone', event.telefone);

        if (await ConviteService.getConvite(event.telefone) != null) {
          throw ValidationException('Membro já tem convite ativo');
        }

        Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();

        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'conviteNew');
        await callable.call({
          'assinaturaId': assinatura.id,
          'estacionamentoId': event.estacionamentoId,
          'nome': event.nome,
          'telefone': event.telefone
        });

        //ConviteService.createConvite(event.nome, event.telefone, event.estacionamentoId);
        yield StateSuccess();
      }
      else if (event is LoadConviteUser) {
        yield StateLoading();
        List<Estacionamento> estacionamentos = await EstacionamentoService.getEstacionamentos();
        yield StateInitialDataConvite(estacionamentos);
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