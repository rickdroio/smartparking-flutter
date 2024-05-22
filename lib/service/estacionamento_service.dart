import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/estacionamento.dart';
import '../model/usuario_model.dart';
import './assinatura_service.dart';
import './usuario_service.dart';

class EstacionamentoService {

  static const String dbPath = 'estacionamentos';

  /*
  static Future<String> createEstacionamento(String assinaturaId, Estacionamento estacionamento) async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRef(assinaturaId);
    DocumentReference doc = ref.collection(dbPath).document();
    doc.setData({
      'endereco': estacionamento.endereco,
      'nome': estacionamento.nome,
      'capacidade': estacionamento.capacidade,
      //'tolerancia': 0
    });
    return doc.documentID;
  }
  */

  static void adicionarEstacionamento(Estacionamento estacionamento) async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    if (estacionamento.id != null && estacionamento.id.isNotEmpty) {
      ref.collection(dbPath).document(estacionamento.id).updateData({ 
        'endereco': estacionamento.endereco,
        'nome': estacionamento.nome,
        'capacidade': estacionamento.capacidade,
        'ativo': estacionamento.ativo,
      });
    }
    else {
      ref.collection(dbPath).document().setData({
        'endereco': estacionamento.endereco,
        'nome': estacionamento.nome,
        'capacidade': estacionamento.capacidade,
        'ativo': estacionamento.ativo,
      });
    }
  }    

  static Future setUsuarioEstacionamento(String estacionamentoId, List<Usuario> usuarios) async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();

    List<String> usuariosStr = List<String>();
    for (var i = 0; i < usuarios.length; i++) {
      usuariosStr.add(usuarios[i].id);
    }

    print('usuariosStr = ${usuariosStr.length.toString()}');
    print('usuarios = ${usuarios.length.toString()}');
    
    ref.collection(dbPath).document(estacionamentoId).updateData({
      'usuarios': FieldValue.arrayUnion(usuariosStr)
    });
  }

  static Future<Estacionamento> getEstacionamento(String id) async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    DocumentSnapshot doc = await ref.collection(dbPath).document(id).get();
    return Estacionamento.of(doc);
  }

  static Future<Estacionamento> getEstacionamentoUsuarioLogado() async {
    String estacionamentoId = await getEstacionamentoProperty();

    //pega o valor do props, caso nao exista pega o primeiro da lista
    if (estacionamentoId == null || estacionamentoId.isEmpty ) {
      Usuario usuario = await UsuarioService.getUsuarioLogado();
      List<Estacionamento> estacionamentos = await getEstacionamentosUsuario(usuario.id);
      if (estacionamentos.length > 0) {
        setEstacionamentoProperty(estacionamentos.first.id);
        return getEstacionamento(estacionamentos.first.id);
      }
      else{
        print('error: usuario sem estacionamento alocado');
        return null;
      }        
    }
    else { //confirma se estaiocnamentoId existe
      Estacionamento estacionamento = await getEstacionamento(estacionamentoId);
      if (estacionamento == null) {
        setEstacionamentoProperty(null);
        return getEstacionamentoUsuarioLogado(); //chama funcao novamente
      }
      else {
        return estacionamento;
      }
    }   
  }

  static Future<Stream<DocumentSnapshot>> getEstacionamentoStreamUsuarioLogado() async {  
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    String estacionamentoId = await getEstacionamentoProperty();
    return ref.collection(dbPath).document(estacionamentoId).snapshots();
  }

  static Future<DocumentReference> getEstacionamentoRefUsuarioLogado() async {  
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    String estacionamentoId = await getEstacionamentoProperty();
    return ref.collection(dbPath).document(estacionamentoId);
  }      

  static Future<List<Estacionamento>> getEstacionamentos() async {
    DocumentReference assinatura = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    List<Estacionamento> items = List<Estacionamento>();

    QuerySnapshot query = await assinatura.collection(dbPath).getDocuments();
    query.documents.forEach((queryItem) => items.add(Estacionamento.of(queryItem)));

    return items;
  }

  static Future<List<Estacionamento>> getEstacionamentosUsuarioLogado() async {
    Usuario usuario = await UsuarioService.getUsuarioLogado();
    return getEstacionamentosUsuario(usuario.id);
  }
  
  static Future<List<Estacionamento>> getEstacionamentosUsuario(String uid) async {
    //APENAS ESTACIONAMENTOS ATIVOS
    DocumentReference assinatura = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    QuerySnapshot query = await assinatura.collection(dbPath).where('usuarios', arrayContains: uid).where('ativo', isEqualTo: true).getDocuments();

    List<Estacionamento> items = List<Estacionamento>();
    query.documents.forEach((queryItem) => items.add(Estacionamento.of(queryItem)));

    return items;
  }

  static Future setEstacionamentoProperty(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('estacionamentoId', id);    
  }

  static Future<String> getEstacionamentoProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('estacionamentoId');
  }   


}