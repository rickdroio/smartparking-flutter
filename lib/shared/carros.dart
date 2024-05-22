import 'dart:convert';
import 'package:flutter/services.dart';

class Carro {
  String modelo;
  String marca;

  Carro({
    this.modelo,
    this.marca
  });

  factory Carro.fromJson(Map<String, dynamic> parsedJson) {
    //print('parsed JSON:' + (parsedJson['MODELO'] as String));
    return Carro(
      modelo: parsedJson['MODELO'] as String,
      marca: parsedJson['MARCA'] as String,
    );
  }
}

class CarrosViewModel {

  static List<Carro> carros = List<Carro>();

  static Future<List<Carro>> carregarCarros() async {
    try {
      String jsonString = await rootBundle.loadString('assets/carros.json');
      List<dynamic> parsedJson = jsonDecode(jsonString);
          
      for (int i = 0; i < parsedJson.length; i++) {
        carros.add(Carro.fromJson(parsedJson[i]));
        String m = carros[i].modelo;
      }
      //return carros;
    }
    catch (e) {
      print(e);
    }
  }
}