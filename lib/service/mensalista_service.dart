import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/mensalista_model.dart';
//import './assinatura_service.dart';
import './estacionamento_service.dart';

class MensalistaService {

  static const String dbPath = 'mensalistas';

  static void adicionar(Mensalista mensalista) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    if (mensalista.id != null && mensalista.id.isNotEmpty) {
      ref.collection(dbPath).document(mensalista.id).updateData({ 
        'nome': mensalista.nome,
        'placa': mensalista.placa,
        'modelo': mensalista.modelo,
      });
    }
    else {
      ref.collection(dbPath).document().setData({
        'nome': mensalista.nome,
        'placa': mensalista.placa,
        'modelo': mensalista.modelo,
      });
    }
  }    

  static Future<Mensalista> getMensalista(String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    DocumentSnapshot doc = await ref.collection(dbPath).document(id).get();
    return Mensalista.of(doc);
  }

  static Future<List<Mensalista>> getMensalistas() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Mensalista> items = List<Mensalista>();

    QuerySnapshot query = await ref.collection(dbPath).getDocuments();
    query.documents.forEach((queryItem) => items.add(Mensalista.of(queryItem)));

    return items;
  }

  static Future<Mensalista> getMensalistaByPlaca(String placa) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    QuerySnapshot query = await ref.collection(dbPath).where('placa', isEqualTo: placa).getDocuments();
    //print('MENSALISTA QUERY ${query.documents.length.toString()}');
    
    if (query.documents.length > 0)
      return Mensalista.of(query.documents.first);
    else
      return null;
  }  



}