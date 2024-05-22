import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/caixa_model.dart';
import '../model/caixa_item_model.dart';
import './estacionamento_service.dart';

class CaixaService {

  static const String dbPath = 'caixa';

  static Future<Caixa> getCaixaAberto({bool createIfNotExist}) async {  
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    QuerySnapshot docs = await ref.collection(dbPath).where('caixaFinalizado', isEqualTo: false).getDocuments();
    print('getCaixaAberto, length = ${docs.documents.length}');
    
    if (docs.documents.length == 0)  { //nao existe caixa aberto
      print('nao existe caixa aberto');
      if (createIfNotExist)
        return await novoCaixa(0.0);
      else
        return null;
    }
    else {
      print('existe caixa aberto');
      DocumentSnapshot doc = docs.documents.first;
      return Caixa.of(doc);
    }   
  }

  static Future<Caixa> novoCaixa(double valorInicial) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    DateTime data = DateTime.now();
    DocumentReference doc = ref.collection(dbPath).document();
    doc.setData({
      'valorInicial': valorInicial,
      'dataAbertura': data,
      'caixaFinalizado': false
    });

    print('novo caixa = ${doc.documentID}');

    return Caixa(valorInicial: valorInicial, dataAbertura: data, id: doc.documentID);
  }

  static void finalizarCaixa(Caixa caixa, List<CaixaItem> itemsCaixa) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    ref.collection(dbPath).document(caixa.id).updateData({
      'caixaFinalizado': true,
      'dataFechamento': caixa.dataFechamento,
      'valorTotal': caixa.valorTotal,      
    });

    itemsCaixa.forEach((item) {
      Firestore.instance.collection(dbPath).document(caixa.id).collection('items').document().setData({
        'formaPgto': item.formaPgto,
        'valorTotal': item.valorTotal
      });
    });    
  }

  static Future<List<Caixa>> getCaixasFechados() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Caixa> caixas = List<Caixa>();

    QuerySnapshot query = await ref.collection(dbPath).where('caixaFinalizado', isEqualTo: true).orderBy('dataFechamento').getDocuments();
    query.documents.forEach((queryItem) => caixas.add(Caixa.of(queryItem)));

    return caixas;
  }  

}
