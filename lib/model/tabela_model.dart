import 'package:cloud_firestore/cloud_firestore.dart';

class Tabela {
  String id;
  String nomeTabela;
  int toleranciaPeriodos; //tolerancia ENTRE periodos
  //String tipoTabela;
  bool tabelaAtiva;
  bool tabelaPadrao;
  //int tolerancia;
  Timestamp createdTabela;
  Timestamp updatedTabela;

  Tabela({this.id, this.nomeTabela, this.createdTabela, this.updatedTabela, this.tabelaAtiva, this.toleranciaPeriodos, this.tabelaPadrao});

  //transformar DOC firebase no modelo
  static Tabela of (DocumentSnapshot doc) {
    return new Tabela(
      id: doc.documentID,
      nomeTabela: doc.data['nomeTabela'],
      tabelaAtiva: doc.data['tabelaAtiva'],
      tabelaPadrao: doc.data['tabelaPadrao'],
      toleranciaPeriodos: doc.data['toleranciaPeriodos'],
      createdTabela: doc.data['createdTabela'],
      updatedTabela: doc.data['updatedTabela'],
    );
  }

  String getNomeTabela(){
    return nomeTabela == null ? '' : nomeTabela;
  }

  String getTabelaAtivaStr(){
    return (tabelaAtiva != null || tabelaAtiva) ? 'Ativo' : 'Desativado';
  }

}