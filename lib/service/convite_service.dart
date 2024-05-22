import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import './assinatura_service.dart';
import '../model/assinatura_model.dart';
import '../model/convite_model.dart';

class ConviteService {

  static const String dbPath = 'convites';

  static Future createConvite(String nome, String telefone, String estacionamentoId) async {
    Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();
    Firestore.instance.collection(dbPath).document().setData({
      'ativo': true,
      'assinatura': assinatura.id,
      'nome': nome,
      'telefone': telefone,
      'estacionamento': estacionamentoId
    });
  }

  static Future<Convite> getConvite(String telefone) async {  
    try {
      Query queryTelefone = Firestore.instance.collection(dbPath).where('telefone', isEqualTo: telefone);
      QuerySnapshot docsTelefone = await queryTelefone.getDocuments();

      if (docsTelefone.documents.length > 0) { //pode ter encontrado +q 1
        QuerySnapshot docsAtivo = await queryTelefone.where('ativo', isEqualTo: true).getDocuments();
        if (docsAtivo.documents.length > 0) {
          return Convite.of(docsAtivo.documents.first);
        } else {
          return null;
        }
      }
      else 
        return null;      
      
    } catch (e) {
      //não tem nenhum id de convite
      print('convite não encontrado');
      return null;
    }
  }

  static Future<List<Convite>> getConvites() async {
    try {
      Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();
      List<Convite> items = List<Convite>();

      QuerySnapshot query = await Firestore.instance.collection(dbPath).where('assinatura', isEqualTo: assinatura.id).where('ativo', isEqualTo: true).getDocuments();
      query.documents.forEach((queryItem) => items.add(Convite.of(queryItem)));

      return items;
    } catch (e) {
      print('nenhum convite encontrado');
      return null;
    }
  } 

  //insert do usuario na tabela dentro de assinaturas sera feita por trigger devido a AUTH do db
  static Future ativarConvite(String conviteId, String uid) async {
    Firestore.instance.collection(dbPath).document(conviteId).updateData({
      'uid': uid
    });
  } 

}