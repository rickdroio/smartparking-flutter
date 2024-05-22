class Utils {

  static DateTime timeStampToDateTime(var timestamp) {
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    }
    else {
      return null;
    }
  }

  static String minutesToHourExtension(int minutos) {
    int horas = minutos ~/ 60;
    int minutosRestantes = minutos % 60;
    return '${horas.toString()}hrs ${minutosRestantes.toString()}min';
  }

}