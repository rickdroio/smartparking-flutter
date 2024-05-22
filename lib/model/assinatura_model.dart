import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/utils.dart';
import 'package:intl/intl.dart';

class Assinatura  {
  String id;
  DateTime dataRegistro;
  DateTime dataFimAssinatura;
  int assinaturaDiasTrial;
  int estacionamentosAtivos;
  String owner;
  List<String> usuarios;
  //TipoAssinatura tipoAssinatura;
  
  Assinatura({this.id, this.dataRegistro, this.dataFimAssinatura, this.assinaturaDiasTrial, this.usuarios, this.owner, this.estacionamentosAtivos});

  //transformar DOC firebase no modelo
  static Assinatura of (DocumentSnapshot doc) {
    return Assinatura(
      id: doc.documentID,
      dataRegistro: Utils.timeStampToDateTime(doc.data['dataRegistro']),
      dataFimAssinatura: Utils.timeStampToDateTime(doc.data['dataFimAssinatura']), //trial
      owner: doc.data['owner'],
      assinaturaDiasTrial: doc.data['assinaturaDiasTrial'],
      estacionamentosAtivos: doc.data['estacionamentosAtivos'] ?? 0,
      usuarios: List<String>.from(doc.data['usuarios']),
    );
  }

  String getdataRegistro(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataRegistro);
  }  

  String getdataFimAssinatura(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataFimAssinatura);
  }
  
}