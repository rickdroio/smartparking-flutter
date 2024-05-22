import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/tabela_model.dart';
import '../model/tabela_item_model.dart';
import './estacionamento_service.dart';

class TabelaService {

  static const String dbPath = 'tabelaPreco';

  static Future<Tabela> getTabela(String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    
    DocumentSnapshot doc =  await ref.collection(dbPath).document(id).get();
    return Tabela.of(doc);
  }

  static Future<TabelaItem> getTabelaItem(String tabelaId, String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    
    DocumentSnapshot doc =  await ref.collection(dbPath).document(tabelaId).collection('items').document(id).get();   
    return TabelaItem.of(tabelaId, doc);
  }  

  static Future<List<Tabela>> getTabelas() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Tabela> items = List<Tabela>();

    QuerySnapshot query = await ref.collection(dbPath).getDocuments();
    query.documents.forEach((queryItem) => items.add(Tabela.of(queryItem)));

    return items;
  }  

  static Future<List<Tabela>> getTabelasAtivas() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Tabela> items = List<Tabela>();

    QuerySnapshot query = await ref.collection(dbPath).where('tabelaAtiva', isEqualTo: true).getDocuments();
    query.documents.forEach((queryItem) => items.add(Tabela.of(queryItem)));

    return items;
  }

  static Future<Tabela> getTabelaPadrao() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    QuerySnapshot query = await ref.collection(dbPath).where('tabelaPadrao', isEqualTo: true).getDocuments();
    
    if (query.documents.first != null) {
      return Tabela.of(query.documents.first);
    }
    else {
      return null;
    }
  }  

  static Future setTabelaPadrao(String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    Tabela tabela = await getTabelaPadrao();
    if (tabela != null) {
      ref.collection(dbPath).document(tabela.id).updateData({'tabelaPadrao': false});
    }

    ref.collection(dbPath).document(id).updateData({'tabelaPadrao': true});
  }

  static Future<List<TabelaItem>> getTabelaItems(String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<TabelaItem> items = List<TabelaItem>();

    QuerySnapshot query = await ref.collection(dbPath).document(id).collection('items').orderBy('periodo').getDocuments();
    query.documents.forEach((queryItem) => items.add(TabelaItem.of(id, queryItem)));

    return items;
  }

  static void adicionarTabela(Tabela tabela) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    if (tabela.id != null && tabela.id.isNotEmpty) {
      ref.collection(dbPath).document(tabela.id).updateData({ 
        'nomeTabela': tabela.nomeTabela,
        'tabelaAtiva': tabela.tabelaAtiva,
        'toleranciaPeriodos': tabela.toleranciaPeriodos,
      });
    }
    else {
      ref.collection(dbPath).document().setData({
        'nomeTabela': tabela.nomeTabela,
        'tabelaAtiva': tabela.tabelaAtiva,
        'toleranciaPeriodos': tabela.toleranciaPeriodos,
      });
    }
  }  

  static adicionarItemTabela(TabelaItem tabelaItem) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    if (tabelaItem.id != null && tabelaItem.id.isNotEmpty) {
      ref.collection(dbPath).document(tabelaItem.tabelaId).collection('items').document(tabelaItem.id).updateData({      
        'preco': tabelaItem.preco,
        'periodo': tabelaItem.periodo,        
        'periodoAux': tabelaItem.periodoAux,
        'tipo': tabelaItem.tipo,
      });
    }
    else {
      ref.collection(dbPath).document(tabelaItem.tabelaId).collection('items').document().setData({
        'preco': tabelaItem.preco,
        'periodo': tabelaItem.periodo,   
        'periodoAux': tabelaItem.periodoAux,
        'tipo': tabelaItem.tipo,
      });        
    }
  }

  static deleteItemTabela(TabelaItem tabelaItem) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    ref.collection(dbPath).document(tabelaItem.tabelaId).collection('items').document(tabelaItem.id).delete();
  }

  static Future<double> calcularPrecoSaida(String tabelaId, int tempoTotal) async {
    List<TabelaItem> items = await getTabelaItems(tabelaId);
    
    //deve vir ordernado por periodo do firebase
    // tipo >>> 1=até, 2=a cada, 3=fixo
    
    List<TabelaItem> itemsAte = items.where((i) => i.tipo==1).toList();
    List<TabelaItem> itemsCada = items.where((i) => i.tipo==2).toList();
    List<TabelaItem> itemsFixo = items.where((i) => i.tipo==3).toList();
    
    //*** TODO considerar tempo de tolerancia entre periodos

    double total = 0;
    
    //itens "Até"
    bool detectedAte = false;
    for(final item in itemsAte){
      if (tempoTotal <= item.periodo) { //qnd achar o primeiro menor, é o período correto
        total = total + item.preco;
        detectedAte = true;
        break;
      }
    }
    if (itemsAte.length>0 && !detectedAte) { //caso tenha chago ate o ultimo periodo e nao caiu na condicao
      total = total + itemsAte.last.preco; 
    }

    //itens "A Cada"
    for(final item in itemsCada){
      if (tempoTotal > item.periodo) { //se for maior que "após X minutos"
        int difTempo = tempoTotal - item.periodo;
        int divisao = difTempo ~/ item.periodoAux;
        int resto = difTempo % item.periodoAux;
        //print('difTempo=${difTempo.toString()}; divisao = ${divisao.toString()}; resto=${resto.toString()}');

        int totalCada = divisao + (resto > 0 ? 1 : 0);

        total = total + (totalCada * item.preco);
      }
    }

    //item fixo
    for(final item in itemsFixo){
      if (tempoTotal > item.periodo){ //se passar, substituir o valor inteiro
        total = item.preco;
      }
    }

    return total;
  }

}