import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  // Vamos atualizar no banco de dados também
  Future<void> toggleFavorite(String token, String userId) async {
    try {
      _toggleFavorite();
      final response = await http.put(
        // Vai enviar para outra coleção do firebase, para salvar só os favoritos
        Uri.parse(
          '${Constants.BASE_URL}/userFavorite/$userId/$id.json?auth=$token',
        ),
        body: jsonEncode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _toggleFavorite();
      }
    } catch (error) {
      // Se der algum erro volta pro que tava antes
      _toggleFavorite();
    }
  }
}
