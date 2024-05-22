enum TipoEntrada {BLUETOOTH_PRINTER, NFC_CARD, QRCODE_CARD}

class TipoEntradaUtils {

  static String getDescricao(TipoEntrada tipo) {
    switch (tipo) {
      case TipoEntrada.BLUETOOTH_PRINTER:
        return 'Impressora Bluetooth';
        break;

      case TipoEntrada.NFC_CARD:
        return 'Cartão NFC';
        break;     

      case TipoEntrada.QRCODE_CARD:
        return 'Cartão QR Code pré-impresso';
        break; 

      default:
        return 'não encontrado';
        break;      
    }      
  }

  static TipoEntrada fromString(String tipo) {
    if (tipo != null)
      return TipoEntrada.values.firstWhere((e) => e.toString() == tipo);
    else
      return null;
  }

}