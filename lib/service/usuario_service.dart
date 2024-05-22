import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/usuario_model.dart';
import '../model/assinatura_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './assinatura_service.dart';

class UsuarioService {

  static const String dbPath = 'usuarios';

  static Future createUsuario(String assinaturaId, Usuario usuario) async {
    DocumentReference assinatura = await AssinaturaService.getAssinaturaRef(assinaturaId);
    assinatura.collection(dbPath).document(usuario.id).setData({
      'admin': usuario.admin,
      'nome': usuario.nome,
      'email': usuario.email,
      'telefone': usuario.telefone,
    });
  }

  static void editUsuario(Usuario usuario) async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    ref.collection(dbPath).document(usuario.id).updateData({
      'admin': usuario.admin,
      //'nome': usuario.nome,
      //'email': usuario.email,
    });
  }   

  static Future<Usuario> getUsuario(String uid) async {
    Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();
    if (assinatura != null) {
      DocumentReference assinaturaRef = await AssinaturaService.getAssinaturaRef(assinatura.id);
      
      DocumentSnapshot doc = await assinaturaRef.collection(dbPath).document(uid).get();
      if (doc!=null && doc.exists)
        return Usuario.of(doc);
      else
        return null;
    }
    else {
      return null;
    }
  }

  static Future<List<Usuario>> getUsuarios() async {
    DocumentReference ref = await AssinaturaService.getAssinaturaRefUsuarioLogado();
    
    List<Usuario> items = List<Usuario>();

    QuerySnapshot query = await ref.collection(dbPath).getDocuments();
    query.documents.forEach((queryItem) => items.add(Usuario.of(queryItem)));

    return items;
  }

  static Future<Usuario> getUsuarioLogado() async {
    String uid = await getFirebaseUid();
    if (uid!=null && uid.isNotEmpty)
      return getUsuario(uid);
    else
      return null;
  }

  static Future<String> getFirebaseUid() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) 
    {
      return user.uid;
    }
    else
      return null;
  }

  static Future sendCodeToPhoneNumber(String phone, PhoneCodeSent codeSent, PhoneVerificationFailed failed) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    final PhoneVerificationCompleted verificationCompleted = (AuthCredential user) {
      print('Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
    };   

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      print("time out");
    };    

    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+55'+phone, 
      timeout: Duration(seconds: 30),
      verificationCompleted: verificationCompleted,
      verificationFailed: failed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
    ).then((_) {print('await verifyPhoneNumber finalizado');});
  }  

  static Future<String> signInWithPhoneNumber(String verificationId, String smsCode) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode
    );

    AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
    return authResult.user.uid;
  }  

  static Future<void> signOut() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    return _firebaseAuth.signOut();
  }  

  static Future<bool> usuarioAtivo() async {
    Usuario usuario = await getUsuarioLogado();
    bool ativo = usuario != null;
    return ativo;
  }

}