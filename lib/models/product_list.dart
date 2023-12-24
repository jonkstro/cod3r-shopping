import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();
  int get itemsCount {
    return items.length;
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  // Adicionar com base no formData da ProductFormPage
  void saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      updateProduct(product);
    } else {
      addProduct(product);
    }
  }

  void updateProduct(Product product) {
    // Se não achar o indice ele retorna index = -1
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      // se for maior que -1 então é válido, logo atualizará pro product
      _items[index] = product;
      notifyListeners();
    }
  }

  void removeProduct(Product product) {
    // Se não achar o indice ele retorna index = -1
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      // se for maior que -1 então é válido, logo removerá o product
      _items.removeWhere((element) => element.id == product.id);
      notifyListeners();
    }
  }
}

// bool _showFavoriteOnly = false;

//   List<Product> get items {
//     if (_showFavoriteOnly) {
//       return _items.where((prod) => prod.isFavorite).toList();
//     }
//     return [..._items];
//   }

//   void showFavoriteOnly() {
//     _showFavoriteOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoriteOnly = false;
//     notifyListeners();
//   }
