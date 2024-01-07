import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/*
 Essa classe vai ter os métodos responsáveis por salvar os dados localmente
 no dispositivo na área de persistencia
 */
class Store {
  // Função assíncrona para salvar uma String no SharedPreferences
  static Future<bool> saveString(String key, String value) async {
    // Obtém a instância do SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Salva a String associada à chave fornecida e retorna o resultado da operação
    return prefs.setString(key, value);
  }

  // Função assíncrona para salvar um Map no SharedPreferences
  static Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    // Converte o Map para uma String JSON usando jsonEncode
    String jsonString = jsonEncode(value);
    // Chama a função saveString para salvar a String JSON associada à chave fornecida
    return saveString(key, jsonString);
  }

  // Ler a string que foi persistida no dispositivo em memória para recuperar o login
  static Future<String> getString(String key,
      [String defaultValue = '']) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      return jsonDecode(await getString(key));
    } catch (_) {
      // Se vier vazio o getString retorna map vazio
      return {};
    }
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
