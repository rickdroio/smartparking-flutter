import 'package:shared_preferences/shared_preferences.dart';
import '../model/tipo_entrada_model.dart';

class ConfiguracoesLocalService {

  static Future saveLocalSetting(String printerAddress, TipoEntrada tipoEntrada) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (printerAddress != null)
      await prefs.setString('printer_address', printerAddress);
    //await prefs.setString('printer_name', printerName);
    if (tipoEntrada != null)
      await prefs.setString('tipo_entrada', tipoEntrada.toString());
  }

  static Future<String> getPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String printerAddress = prefs.getString('printer_address');    
    return printerAddress;
  }

  static Future<TipoEntrada> getTipoEntrada() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tipo = prefs.getString('tipo_entrada');
    return TipoEntradaUtils.fromString(tipo);
  }  

  static Future setDefaults() async {
    TipoEntrada tipo = await getTipoEntrada();
    if (tipo == null)
      saveLocalSetting(null, TipoEntrada.BLUETOOTH_PRINTER);
  }

}