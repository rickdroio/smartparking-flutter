import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../shared/utils.dart';
import './tipo_entrada_model.dart';

class Entrada {
  String id;
  String placa;
  String modelo;
  String tipoEntradaId;
  TipoEntrada tipoEntrada;
  bool entradaFinalizada;
  DateTime dataLocal;
  DateTime dataSaidaLocal;
  int tempoTotal;
  double valorTotal;
  String tabelaId;
  String nomeTabela;
  String formaPgto;
  String caixaId;
  bool isMensalista;
  //double valorPago;
  //double troco;


  Entrada({this.id, this.placa, this.modelo, this.tipoEntradaId, this.tipoEntrada, this.dataLocal, this.dataSaidaLocal, this.entradaFinalizada, 
    this.tempoTotal, this.valorTotal, this.tabelaId, this.nomeTabela, this.formaPgto, this.caixaId, this.isMensalista});

  //transformar DOC firebase no modelo
  static Entrada of (DocumentSnapshot doc) {
    return Entrada(
      id: doc.documentID,
      placa: doc.data['placa'],
      modelo: doc.data['modelo'],
      tipoEntradaId: doc.data['tipoEntradaId'],
      tipoEntrada: TipoEntradaUtils.fromString(doc.data['tipoEntrada']),
      dataLocal: Utils.timeStampToDateTime(doc.data['dataLocal']),
      dataSaidaLocal: Utils.timeStampToDateTime(doc.data['dataSaidaLocal']),
      entradaFinalizada: doc.data['entradaFinalizada'],
      tempoTotal: doc.data['tempoTotal'],
      valorTotal: doc.data['valorTotal'],
      tabelaId: doc.data['tabelaId'],
      nomeTabela: doc.data['nomeTabela'],
      formaPgto: doc.data['formaPgto'],
      caixaId: doc.data['caixaId'],
      isMensalista: doc.data['isMensalista'] ?? false,
      
      //valorPago: doc.data['valorPago'],
      //troco: doc.data['troco'],
    );
  }  

  /*
  String getCodEntrada() {
    var f = NumberFormat("00000", "en_US");
    if (codEntrada != null)
      return f.format(codEntrada);
    else
      return '';
  }
  */

  String getvalorTotal() {
    if (valorTotal != null)
      return NumberFormat.currency(
        decimalDigits: 2,
        locale: 'pt_br',
        symbol: 'R\$'
      ).format(valorTotal);
    else
      return null;
  }

  String getdataLocal(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataLocal);
  }
  
  String getdataLocalPrint(){
    return DateFormat('dd-MM-yyyy kk:mm').format(dataLocal);
  }

  String getdataSaidaLocal(){
    return DateFormat('dd-MM-yyyy – kk:mm').format(dataSaidaLocal);
  }

}