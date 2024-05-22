import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xmllib;
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/sinesp_model.dart';

//based on https://github.com/Sorackb/sinesp-api
//old- based on https://github.com/bbarreto/sinesp-nodejs/blob/master/index.js
//old- talvez https://github.com/casadosdados/sinesp-consulta-placa/blob/master/src/app/sinesp.js

class SinespService {

  static const HOST = 'cidadao.sinesp.gov.br';
  static const ENDPOINT = '/sinesp-cidadao/mobile/consultar-placa/';
  static const SERVICEVERSION = 'v5';

  /** Chave secreta para criptografia */
  static const SECRET = '0KnlVSWHxOih3zKXBWlo';
  static const DEVICE = '3580873862227064803';
  static const USER_AGENT = 'Android-GCM/1.5 (victara MPES24.49-18-7)';
  static const DEVICE_COMPLEMENT = '6185646517745801705';
  static const URL_GOOGLE_FCM = 'https://android.clients.google.com/c2dm/register3';

  static const ANDROID_VERSION = '6.0';

  static Future<Sinesp> consultarPlaca(String placa) async{
    
    if (placa.isEmpty) { //verificar se placa foi informada
      print('Informe o parâmetro placa.');
      return Future.error('Informe o parâmetro placa.');
    } 

    String firebaseToken = await getFirebaseToken();
    String body = generateBody(placa, firebaseToken);

    Sinesp sinesp = await requestHttp(body, firebaseToken);
    if (sinesp == null) //tentar novamente (funcao HTTP ja zera a property)
      print('tentando novamente...');
      await Future.delayed(Duration(seconds: 2));
      sinesp = await requestHttp(body, firebaseToken);

    return sinesp;
  }

  static Future<String> getFirebaseToken() async { 
    //verificar qnt de request para trocar o token (50 max)

    String token = await getFirebaseTokenProperty();
    print('TOKEN FROM PROPERTY = $token');
    if (token == null || await getFirebaseTokenCountProperty() > 50) {
      print('NEW SINESP TOKEN REQUESTED');
      token = await requestToken();
      setFirebaseTokenProperty(token);
    }

    return token;
  }

  static Future setFirebaseTokenProperty(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firebaseToken', token);
  }

  static Future<String> getFirebaseTokenProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('firebaseToken');
    return token;
  }

  static Future<int> getFirebaseTokenCountProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //controlar max 50 requisições com o mesmo token
    //le e já incrementa
    int count = prefs.getInt('firebaseToken_count') ?? 0 + 1;
    prefs.setInt('firebaseToken_count', count);

    print('firebaseToken_count = ${count.toString()}');

    return count;
  }  

  static Future<String> requestToken() async { 
    String hash = randomString(11);

    Map<String, String> params = {
      'X-subtype': '905942954488',
      'sender': '905942954488',
      'X-app_ver': '49',
      'X-osv': '23',
      'X-cliv': 'fiid-12451000',
      'X-gmsv': '17785018',
      'X-appid': hash,
      'X-scope': '*',
      'X-gmp_app_id': '1%3A905942954488%3Aandroid%3Ad9d949bd7721de40',
      'X-app_ver_name': '4.7.4', 
      'app': 'br.gov.sinesp.cidadao.android',
      'device': DEVICE,
      'app_ver': '49',
      'info': 'szkyZ1yvKxIbENW7sZq6nvlyrqNTeRY',
      'gcm_ver': '17785018',
      'plat': '0',
      'cert': 'daf1d792d60867c52e39c238d9f178c42f35dd98',
      'target_ver': '26',
    };
    
    String body = '';
    params.forEach((p, v) => body += '$p=$v&');

    Map<String, String> headers = {
      'user-agent': USER_AGENT,
      'Authorization': 'AidLogin $DEVICE:$DEVICE_COMPLEMENT',
      'Content-type': 'application/x-www-form-urlencoded',
      'app': 'br.gov.sinesp.cidadao.android',
      'gcm_ver': '17785018',
    }; 

    return await http.post(URL_GOOGLE_FCM, body: body,headers: headers).then( (r) {
      //print('URL_GOOGLE_FCM HTTP RESPONSE:');
      //print(r.body.toString()); 
      String token = r.body.toString().replaceAll('token=', '');
      return token;
    }).catchError((error) => print(error.toString()));
  }

  static String randomString(int length) {
    String result = '';
    final String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final int charactersLength = characters.length;

    for (var i = 0; i < length; i++) {
      double index = Random().nextDouble() * charactersLength;
      result += characters[index.toInt()];
    }

    return result;
  }

  static String generateToken(String placa) {
    /** Criptografa a placa usando a chave do aplicativo */
    String secret = '#$ANDROID_VERSION#$SECRET';
    //print(secret);
    
    var key = utf8.encode(placa+secret);
    var bytes = utf8.encode(placa);
    var hmac = Hmac(sha1, key);
    var digest = hmac.convert(bytes);
    return digest.toString();    
  }

  static String generateBody(String placa, String firebaseToken) {

     RegExp regExp = RegExp(r':(.+)', caseSensitive: false, multiLine: false);
     String authorization = regExp.firstMatch(firebaseToken).group(0); //pega segunda parte do token gerado
     String token = generateToken(placa);
     var data = DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19);

    /** Cria o XML de chamada do serviço SOAP */
    String xml = '''
      <v:Envelope 
      xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">
      <v:Header>
        <b>LGE Nexus 5</b>
        <c>ANDROID</c>
        <d>$ANDROID_VERSION</d>
        <e>4.7.4</e>
        <f>192.168.0.100</f>
        <g>$token</g>
        <h>0.0</h>
        <i>0.0</i>
        <j/>
        <k/>
        <l>$data</l>
        <m>8797e74f0d6eb7b1ff3dc114d4aa12d3</m>    
        <n>$authorization</n>    
      </v:Header>
      <v:Body xmlns:n0="http://soap.ws.placa.service.sinesp.serpro.gov.br/">
          <n0:getStatus>
            <a>$placa</a>
          </n0:getStatus>
        </v:Body>
      </v:Envelope> ''';

    return xml;
  }

  static Future<Sinesp> requestHttp(String body, String firebaseToken) async {
    const url = 'https://$HOST$ENDPOINT$SERVICEVERSION';

    return await http.post(url,
      body: body,
      headers: {
        //'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        //'User-Agent': 'SinespCidadao / 3.0.2.1 CFNetwork / 758.2.8 Darwin / 15.0.0',
        //'Content-length': body.length.toString(),
        //'Authorization': 'Token $firebaseToken',
        HttpHeaders.authorizationHeader: 'Token $firebaseToken',
        //'Accept': 'text/xml',
        //'Host': 'cidadao.sinesp.gov.br',
      },
    ).then( (r) {
      print('SINESP HTTP RESPONSE:');
      print(r.body.toString());

      var document = xmllib.parse(r.body.toString());
      String codigoRetorno = document.findAllElements('codigoRetorno').first.text;
      print('codigoRetorno SINESP = $codigoRetorno');

      if (codigoRetorno != '0' && codigoRetorno != '3') { //3 = carro nao encontrado
        //tentar gerar o codigo firebase na proxima vez
        print('codigoRetorno = $codigoRetorno, zerando property...');
        setFirebaseTokenProperty(null);
      }
      
      if (codigoRetorno == '0') {
        print('SINESP RETORNO MODEL');
        return Sinesp(
          codigoRetorno: document.findAllElements('codigoRetorno').first.text,
          mensagemRetorno: document.findAllElements('mensagemRetorno').first.text,
          codigoSituacao: document.findAllElements('codigoSituacao').first.text,
          situacao: document.findAllElements('situacao').first.text,
          modelo: document.findAllElements('modelo').first.text,
          marca: document.findAllElements('marca').first.text,
          cor: document.findAllElements('cor').first.text,
          ano: document.findAllElements('ano').first.text,
          anoModelo: document.findAllElements('anoModelo').first.text,
          placa: document.findAllElements('placa').first.text,
          uf: document.findAllElements('uf').first.text,
          municipio: document.findAllElements('municipio').first.text
        );
      } 
    })
    .catchError((error) {
      print('HEEP SINESP ERROR');
      print(error);
      //return Future.error(error);
    });    

  }

 

}