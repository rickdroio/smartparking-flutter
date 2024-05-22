import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabelaItem {
  String tabelaId;
  String id;
  int tipo; //1=até, 2=a cada, 3=fixo
  int periodo;
  int periodoAux;
  double preco;

  TabelaItem({this.id, this.periodo, this.preco, this.tabelaId, this.periodoAux, this.tipo});

  //transformar DOC firebase no modelo
  static TabelaItem of (String tabelaId, DocumentSnapshot doc) {
    return new TabelaItem(
      tabelaId: tabelaId,
      id: doc.documentID,
      periodo: doc.data['periodo'],
      periodoAux: doc.data['periodoAux'],
      preco: doc.data['preco'],
      tipo: doc.data['tipo'],
    );
  }

  String getPreco() {
    return NumberFormat.currency(
      decimalDigits: 2,
      locale: 'pt_br',
      symbol: 'R\$'
    ).format(preco);
  } 

  String getPeriodo(){
    return periodo.toString()+'min';
  } 

  String getDescricao(){
    if (tipo == 1){
      return 'até ${periodo.toString()} min';
    }
    else if (tipo == 2) {
      return 'a cada ${periodoAux.toString()} min, após ${periodo.toString()} min';
    }
    else if (tipo == 3) {
      return 'valor fixo após ${periodo.toString()} min';
    }
    else
      return 'error';
  }



}