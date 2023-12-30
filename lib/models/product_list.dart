import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
// import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  // Não vamos mais iniciar mockado, pois agora vai ser pego do backend
  // final List<Product> _items = dummyProducts;
  final List<Product> _items = [];

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
    final response =
        await http.get(Uri.parse('${Constants.BASE_URL}/produtos.json'));
    // Vai dar dump se vier vazio no firebase
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      // Vou adicionar na lista vazia os itens do backend que vai ser carregado
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          //Se vier int ele parseia pra double evitando quebrar a aplicação
          price: double.parse(productData['price'].toString()),
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
      // Obs.: Deve sempre ter ".json" no final senão o FIREBASE dá erro.
      // Outros backend (ex.: sprintboot) precisa não adicionar o ".json" no final.
      Uri.parse('${Constants.BASE_URL}/produtos.json'),
      body: jsonEncode(
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
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

  Future<void> updateProduct(Product product) async {
    // Se não achar o indice ele retorna index = -1
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      // método patch vai atualizar só o que tá sendo passado.
      // testar se o put funciona no backend do spring validando campos vazios
      final response = await http.patch(
        // Obs.: Deve sempre ter ".json" no final senão o FIREBASE dá erro.
        // Outros backend (ex.: sprintboot) precisa não adicionar o ".json" no final.
        Uri.parse('${Constants.BASE_URL}/produtos/${product.id}.json'),
        body: jsonEncode(
          {
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );

      // se for maior que -1 então é válido, logo atualizará pro product
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    // Se não achar o indice ele retorna index = -1
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      final Product product = _items[index];
      // primeiro vamos remover da lista, pra depois remover do backend. se der problema
      // no backend a gente adiciona o elemento de volta
      _items.remove(product);
      notifyListeners();
      final response = await http.delete(
        // Obs.: Deve sempre ter ".json" no final senão o FIREBASE dá erro.
        // Outros backend (ex.: sprintboot) precisa não adicionar o ".json" no final.
        Uri.parse('${Constants.BASE_URL}/produtos/${product.id}.json'),
      );

      // Se der algum erro no backend, vamos reinserir o item removido na mesma posição de antes
      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        // vai estourar essa exception personalizada lá no componente product item
        throw HttpException(
          msg: "Não foi possível excluir o item: ${response.body}",
          statusCode: response.statusCode,
        );
      }
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
