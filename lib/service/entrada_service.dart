import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/entrada_model.dart';
import '../model/estacionamento.dart';
import './estacionamento_service.dart';
import '../service/printer_service.dart';

class EntradaService {

  static const placaRegex = r'[a-zA-Z]{3}[0-9]{4}|[a-zA-Z]{3}[0-9]{1}[a-zA-Z]{1}[0-9]{2}';

  static const String dbPath = 'entradas';

  static Future<List<Entrada>> getEntradasAbertas() async{
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Entrada> items = List<Entrada>();

    QuerySnapshot query = await ref.collection(dbPath).where('entradaFinalizada', isEqualTo: false).getDocuments();
    query.documents.forEach((queryItem) => items.add(Entrada.of(queryItem)));

    return items;
  }

  static Future<Entrada> getEntrada(String id) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    DocumentSnapshot doc = await ref.collection(dbPath).document(id).get();
    return Entrada.of(doc);
  }    

  static Future<QuerySnapshot> procurarPlaca(String placa) async { //nao atualiza realdatabase
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    return ref.collection(dbPath).where('placa', isEqualTo: placa).where('entradaFinalizada', isEqualTo: false).getDocuments();
  }

  static Future<Entrada> procurarTipoEntradaId(String tipoEntradaId) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    QuerySnapshot query = await ref.collection(dbPath)
      .where('tipoEntradaId', isEqualTo: tipoEntradaId)
      .where('entradaFinalizada', isEqualTo: false).getDocuments();

    if (query.documents.length > 0)
      return Entrada.of(query.documents.first);
    else
      return null;
  }

  static Future<String> adicionarEntradaId() async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    DocumentReference entradaRef = ref.collection(dbPath).document();
    return entradaRef.documentID;
  }
  
  static Future adicionarEntrada(Entrada entrada) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    
    ref.collection(dbPath).document(entrada.id).setData({
      'placa': entrada.placa.toUpperCase(),
      'dataLocal': entrada.dataLocal,
      'modelo': entrada.modelo,
      'tipoEntrada': entrada.tipoEntrada.toString(),
      'tipoEntradaId': entrada.tipoEntradaId,
      'isMensalista': entrada.isMensalista,
      'entradaFinalizada': false
    });
  }

  static void finalizarSaida(Entrada entrada) async {
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();

    ref.collection(dbPath).document(entrada.id).updateData({
      'entradaFinalizada': true,
      'dataSaidaLocal': entrada.dataSaidaLocal,
      'tempoTotal': entrada.tempoTotal,
      'valorTotal': entrada.valorTotal,
      'tabelaId': entrada.tabelaId,
      'nomeTabela': entrada.nomeTabela,
      'formaPgto': entrada.formaPgto,
      'caixaId': entrada.caixaId,
      //'valorPago': entrada.valorPago,
      //'troco': entrada.troco,
    });
  }  

  static Future<List<Entrada>> getEntradasCaixa(String caixaId) async{
    DocumentReference ref = await EstacionamentoService.getEstacionamentoRefUsuarioLogado();
    List<Entrada> items = List<Entrada>();

    QuerySnapshot query = await ref.collection(dbPath).where('caixaId', isEqualTo: caixaId).getDocuments();
    query.documents.forEach((queryItem) => items.add(Entrada.of(queryItem)));

    return items;
  }  
 
  static Future imprimirReciboEntrada(Entrada entrada) async {
    PrinterService printerService = PrinterService(); //ja tenta conectar
    Estacionamento estacionamento = await EstacionamentoService.getEstacionamentoUsuarioLogado();

    if (await printerService.isConnect()) {
      if (estacionamento.nome.length > 16) { //quebrar em 2 linhas no espaço
        int indiceEspaco = estacionamento.nome.indexOf(' ');
        String nome1 = estacionamento.nome.substring(0, indiceEspaco);
        String nome2 = estacionamento.nome.substring(indiceEspaco);

        await printerService.printText(msg: nome1, size: 2, align: 1);
        await printerService.printText(msg: nome2, size: 2, align: 1);
      }
      else
        await printerService.printText(msg: estacionamento.nome, size: 2, align: 1);


      await printerService.feedLine();
      await printerService.printText(msg: 'Data/Hora: ${entrada.getdataLocalPrint()}', size: 1, align: 1);
      await printerService.feedLine();
      await printerService.printQRCode(entrada.id);
      await printerService.feedLine();
      await printerService.printText(msg: 'Placa: ${entrada.placa}', size: 3, align: 1);
      await printerService.feedLine();       
      await printerService.feedLine();       
    }
  }

  static bool validarPlaca(String placa) {
    RegExp regExp = RegExp(placaRegex, caseSensitive: false, multiLine: false);
    return regExp.hasMatch(placa);
  }

  static String getPlaca(String placa) {
    RegExp regExp = RegExp(placaRegex, caseSensitive: false, multiLine: false);
    return regExp.stringMatch(placa);
  }



}