import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:smartparking_flutter2/service/assinatura_service.dart';
import '../model/assinatura_model.dart';
import '../model/subscription_model.dart';

class SubscriptionService {

  static const String SKU_NOPLAN = 'SKU_NOPLAN';
  static const String SKU_TRIAL = 'SKU_TRIAL';
  static const String SKU_BASICO = 'rdr.micro_parking';

  static const String dbPath = 'subscriptions';

  static Future<List<Subscription>> getSubscriptionfromStore() async{
    final Set<String> _productLists = <String>[SKU_BASICO].toSet();

    final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_productLists);
    if (response.notFoundIDs.isNotEmpty) {
      return Future.error('Erro de conexão com o Google Play');
    }

    List<Subscription> lista = List<Subscription>();

    for(var product in response.productDetails) {
      Subscription subscription = await getSubscriptionDescription(product.id);
      subscription.preco = product.price;
      subscription.productDetails = product;
      lista.add(subscription);      
    }

    return lista;
  }

  static Future<bool> buySubscription(Subscription subscription) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: subscription.productDetails);
    return InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  static Future<Subscription> getSubscriptionDescription(String sku) async {
    print('getSubscriptionDescription = $sku');
    DocumentSnapshot doc = await Firestore.instance.collection(dbPath).document(sku).get();
    Subscription subscription = Subscription.of(doc);
    subscription.ativo = sku != SKU_NOPLAN ? true : false;
    return subscription;
  }

  static Future<Subscription> getSubscriptionUsuarioLogado() async {
    //TODO - TRIAL_ATIVO >> evitar q usuario volta data do sistema
    Assinatura assinatura = await AssinaturaService.getAssinaturaUsuarioLogado();

    if (assinatura.dataFimAssinatura.isAfter(DateTime.now())) { //PERIODO TRIAL
      Subscription subscription = await getSubscriptionDescription(SKU_TRIAL);
      subscription.detalhes = '${assinatura.assinaturaDiasTrial.toString()} dias';
      return subscription;
    }
    else {
      final bool available = await InAppPurchaseConnection.instance.isAvailable();
      if (!available) {
        print('InAppPurchaseConnection NOT AVAILALBE');
      }    

      final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
      if (response.error != null) {
          print('Erro ao obter dados da sua assinatura >> ${response.error.code.toString()}'); //restore_transactions_failed
          print('utilizando valor da property');
          String productID = await getSubscriptionProperty();
          Subscription subscription = await getSubscriptionDescription(productID);
          return  subscription;
      }

      if (response.pastPurchases.length > 0) { //encontrou assinatura Google Play
        String productID = response.pastPurchases.first.productID;
        Subscription subscription = await getSubscriptionDescription(productID);
        subscription.ativo = true;
        setSubscriptionProperty(productID); //grava valor, em caso de problema de comunicação com google play utiliza esse
        return subscription;
      }
      else { //SEM ASSINATURA OU PERIODO TRIAL
        return  await getSubscriptionDescription(SKU_NOPLAN);
      }     
    }
  }

    static Future setSubscriptionProperty(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('setSubscriptionProperty() = $id');
    prefs.setString('subscription', id);    
  }

  static Future<String> getSubscriptionProperty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('subscription');
    print('getSubscriptionProperty() = $id');
    return id;
  }  

  

}