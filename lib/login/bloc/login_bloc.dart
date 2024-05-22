import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'login_event.dart';
import 'login_state.dart';

import '../../service/usuario_service.dart';
import '../../service/error_service.dart';
import '../../service/promo_service.dart';
import '../../service/assinatura_service.dart';
import '../../service/convite_service.dart';

import '../../model/convite_model.dart';
import '../../model/login_model.dart';
import '../../model/assinatura_model.dart';
import '../../shared/validators.dart';
import '../../shared/validation_exception.dart';

import '../../service/device_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  @override
  void onTransition(Transition<LoginEvent, LoginState> transition) {
    print(transition.toString());
  }

  @override
  LoginState get initialState => StateInitial();
  
  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    try 
    {
      if (event is InitialEvent) {
        yield StateInitial();
      }
      else if (event is LoginError) {
        yield StateError(event.error);
      }
      else if (event is UserPhoneLogin) {
        //apenas verificar se é numero de telefone válido e ir para tela de confirmacao de SMS
        yield StateLoading();
        Validators.phonePattern('Telefone', event.phone);

        await UsuarioService.sendCodeToPhoneNumber(event.phone, event.codeSent, event.verificationFailed);

        //yield StateSuccessPhone(event.phone); >> feito por callback
      }
      else if (event is UserPhoneConfirmation) {
        yield StateLoading();
        String uid = await UsuarioService.signInWithPhoneNumber(event.verificationId, event.smsCode); //se falhar ele ja gera throw error
        Assinatura assinatura = await AssinaturaService.findAssinaturaUsuario(uid);
        bool novoUser = assinatura == null;
        LoginStatus loginStatus;
        Convite convite;
        
        if (novoUser) {
          convite = await ConviteService.getConvite(event.telefone);
          if (convite != null) {
            loginStatus = LoginStatus.USER_INVITED;
            ConviteService.ativarConvite(convite.id, uid);
            DeviceService.setNewDevice(); //registrar device que está conectando
          }
          else{ 
            loginStatus = LoginStatus.USER_NEW;
          }
        }
        else{
          loginStatus = LoginStatus.USER_REGISTERED;
          AssinaturaService.setAssinaturaProperty(assinatura.id); //evitar diversas consultas ao getAssinaturaRefUsuarioLogado em paralelo no primeiro acesso
          DeviceService.setNewDevice(); //registrar device que está conectando
        } 

        yield StateSuccessConfirmation(uid, loginStatus, convite);
      }
      else if (event is UserNew) {
        yield StateLoading();

        Validators.notEmpty('Nome Cliente', event.usuario.nome);
        Validators.emailPattern('Email', event.usuario.email);
        Validators.notEmpty('Nome do estacionamento', event.estacionamento.nome);
        Validators.notEmpty('Endereço do estacionamento', event.estacionamento.endereco);

        if (event.promo.isNotEmpty && !await PromoService.checkPromo(event.promo)) { //se promoCode nao for valido
          throw ValidationException('Código Promocional expirado ou inválido');
        }

        final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'assinaturaNew');
        final HttpsCallableResult result = await callable.call({
          'uid': event.usuario.id,
          'nomeUsuario': event.usuario.nome,
          'emailUsuario': event.usuario.email,
          'telefoneUsuario': event.usuario.telefone,
          'enderecoEstacionamento': event.estacionamento.endereco,
          'nomeEstacionamento': event.estacionamento.nome,
          'capacidadeEstacionamento': event.estacionamento.capacidade,
          'promo': event.promo,
        });

        String assinaturaId = result.data['assinaturaId'];

        AssinaturaService.setAssinaturaProperty(assinaturaId);
        
        DeviceService.setNewDevice(); //registrar device que está conectando
      
        yield StateSuccessNewUser(assinaturaId);
      }

    }
    on ValidationException catch(error) {
      print('ValidationException ${error.message.toString()}');
      yield StateError(error.message);
    }    
    catch (error) {
      print('error ${error.message.toString()}');
      yield StateError(ErrorService.translate(error));
    }
  }   



}