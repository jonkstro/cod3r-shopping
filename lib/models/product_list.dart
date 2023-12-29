import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  // Não vamos mais iniciar mockado, pois agora vai ser pego do backend
  // final List<Product> _items = dummyProducts;
  final List<Product> _items = [];
  final String _baseUrl =
      'https://shop-cod3r-df19c-default-rtdb.firebaseio.com';

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();
  int get itemsCount {
    return items.length;
  }

  // Carregar os produtos do backend. Esse método vai ser chamado na página inicial de
  // produtos: ProductsOverviewPage.
  Future<void> loadProducts() async {
    // limpar a lista de produtos antes de carregar pra evitar que duplique
    _items.clear();
    final response = await http.get(Uri.parse('$_baseUrl/produtos.json'));
    if (response.body == 'null') return; // Vai dar dump se vier vazio
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      // Vou adicionar na lista vazia os itens do backend que vai ser carregado
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ),
      );
    });
    notifyListeners();
  }

  // Adicionar com base no formData da ProductFormPage
  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      // Vai retornar um Future<void> do método que tá chamando
      return updateProduct(product);
    } else {
      // Vai retornar um Future<void> do método que tá chamando
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    // await vai esperar esse método até receber uma resposa
    final response = await http.post(
      // Obs.: Deve sempre ter ".json" no final senão dá erro
      Uri.parse('$_baseUrl/produtos.json'),
      body: jsonEncode(
        {
          'name': 'product.name',
          'description': 'product.description',
          'price': 'product.price',
          'imageUrl': 'product.imageUrl',
          'isFavorite': 'product.isFavorite',
        },
      ),
    );

    // O id criado pelo o firebase tá vindo como 'name'
    final id = jsonDecode(response.body)['name'];
    _items.add(
      // Adicionar em memória um produto identico ao do firebase
      Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      ),
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product product) {
    // Se não achar o indice ele retorna index = -1
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      // se for maior que -1 então é válido, logo atualizará pro product
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
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
