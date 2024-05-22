import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/assinatura_model.dart';
import './usuario_service.dart';

class AssinaturaService {

  static const String dbPath = 'assinaturas';

  static Future<DocumentReference> getAssinaturaRef(String id) async {
    return Firestore.instance.collection(dbPath).document(id);      
  }

  static Future<DocumentReference> getAssinaturaRefUsuarioLogado() async {  
    print('getAssinaturaRefUsuarioLogado()');
    //gravar assinatura para economizar procura no firebase
    String assinaturaId = await getAssinaturaProperty();

    if (assinaturaId == null || assinaturaId.isEmpty) {
      Assinatura assinatura = await findAssinaturaUsuarioLogado();

      if (assinatura != null) {
        //gravar assinatura para economizar procura no firebase
        setAssinaturaProperty(assinatura.id);
        return getAssinaturaRef(assinatura.id);
      }
      else {
        return null;
      }
    }
    else { //nao confirma se assinatura existe, para nao gerar custo adicional
      DocumentReference doc = await getAssinaturaRef(assinaturaId);
      if (doc == null) {//erro de auth
        setAssinaturaProperty(null);
        return getAssinaturaRefUsuarioLogado();
      }
      else return doc;
    }
  }  

  static Future<Assinatura> getAssinaturaUsuarioLogado() async {  
    print('getAssinaturaUsuarioLogado()');
    //gravar assinatura para economizar procura no firebase
    String assinaturaId = await getAssinaturaProperty();

    if (assinaturaId == null || assinaturaId.isEmpty) {      
      Assinatura assinatura = await findAssinaturaUsuarioLogado();

      if (assinatura != null) {
        //gravar assinatura para economizar procura no firebase
        setAssinaturaProperty(assinatura.id);
        return assinatura;        
      }
      else {
        return null;
      }
    }
    else {
      DocumentReference doc = await getAssinaturaRef(assinaturaId);
      if (doc == null) {//erro de auth
        print('getAssinaturaUsuarioLogado ERROR >> assinatura da property errado ');
        setAssinaturaProperty(null);
        return getAssinaturaUsuarioLogado();
      }
      else return getAssinatura(assinaturaId);
    }
  }  

  static Future<Assinatura> findAssinaturaUsuario(String uid) async {
    try {
      QuerySnapshot docs = await Firestore.instance.collection(dbPath).where('usuarios', arrayContains: uid).getDocuments();
      if (docs.documents.length > 0) {
        DocumentSnapshot doc = docs.documents.first;
        return Assinatura.of(doc);
      }
      else {
        return null;
      }
    } catch (e) {
      //não tem auth
      return null;
    }      
  }

  static Future<Assinatura> findAssinaturaUsuarioLogado() async {
    String uid = await UsuarioService.getFirebaseUid();
    return findAssinaturaUsuario(uid);   
  }  

  static Future<Assinatura> getAssinatura(String id) async {
    DocumentSnapshot doc = await Firestore.instance.collection(dbPath).document(id).get();
    Assinatura assinatura = Assinatura.of(doc);
    return assinatura;    
  }

  static Future setAssinaturaProperty(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('setAssinaturaProperty() = $id');
    prefs.setString('assinaturaId', id);    
  }

  static Future<String> getAssinaturaProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('assinaturaId');
    print('getAssinaturaProperty() = $id');
    return id;
  }  

  static Future<bool> isPrimeiroAcesso() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool primeiroLogin = prefs.getBool('primeiroAcesso') ?? true;

    if (primeiroLogin) prefs.setBool('primeiroAcesso', false);

    return primeiroLogin;  
  }    

}