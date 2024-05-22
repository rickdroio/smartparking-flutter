import 'validation_exception.dart';

class Validators {

  static void notEmpty(String campo, String value)  {
    if (value == null || value.isEmpty)
      throw ValidationException('$campo não pode ser vazio');
  }  

  static void minLength(String campo, int size, String value) {
    if (value.length < size)
      throw ValidationException('$campo deve ser maior que $size');
  }

  static void greaterThanZeroInt(String campo, int value) {
    if (value == null || value<=0)
      throw ValidationException('$campo deve ser maior que zero');
  }

  static void greaterEqualThanZeroInt(String campo, int value) {
    if (value == null || value<0)
      throw ValidationException('$campo não pode ser negativo');
  }   

  static void greaterThanZeroDouble(String campo, double value) {
    if (value == null || value<=0)
      throw ValidationException('$campo deve ser maior que zero');
  }  

  static void greaterEqualThanZeroDouble(String campo, double value) {
    if (value == null || value<0)
      throw ValidationException('$campo não pode ser negativo');
  } 

  static void emailPattern(String campo, String value) {
    RegExp regExp = new RegExp(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$", caseSensitive: false, multiLine: false);
    if (!regExp.hasMatch(value))
      throw ValidationException('$campo inválido');
  }

  static void phonePattern(String campo, String value) {
    RegExp regExp = new RegExp(r"[0-9]{11}$", caseSensitive: false, multiLine: false);
    if (!regExp.hasMatch(value))
      throw ValidationException('$campo inválido');
  }  


}