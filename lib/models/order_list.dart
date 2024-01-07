import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';

class OrderList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Order> _items = [];

  OrderList([
    this._token = '',
    this._userId = '',
    this._items = const [],
  ]);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadOrders() async {
    // limpar a lista de pedidos antes de carregar pra evitar que duplique
    _items.clear();
    final response = await http.get(
        Uri.parse('${Constants.BASE_URL}/pedidos/$_userId.json?auth=$_token'));
    // Vai dar dump se vier vazio no firebase
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      _items.add(
        Order(
          id: orderId,
          // PARSEAR PRA DOUBLE PRA NÃO QUEBRAR (FIREBASE SOMENTE)
          total: double.parse(orderData['total'].toString()),
          date: DateTime.parse(orderData['date']),
          // Vai ter que fazer um mapping dos produtos que tão sendo recebido para poder
          // converter em CartItem.
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['name'],
              quantity: item['quantity'],
              // PARSEAR PRA DOUBLE PRA NÃO QUEBRAR (FIREBASE SOMENTE)
              price: double.parse(item['price'].toString()),
            );
          }).toList(),
        ),
      );
    });
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    // await vai esperar esse método até receber uma resposa
    final response = await http.post(
      // Obs.: Deve sempre ter ".json" no final senão o FIREBASE dá erro.
      // Outros backend (ex.: sprintboot) precisa não adicionar o ".json" no final.
      Uri.parse('${Constants.BASE_URL}/pedidos/$_userId.json?auth=$_token'),
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(), //formatar a data
          // fazer um mapping nos produtos pra adicionar no firebase o objeto certinho
          // Obs.: Verificar se num backend relacional precisaria enviar assim ou só id do produto
          'products': cart.items.values
              .map(
                (cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'name': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                },
              )
              .toList(),
        },
      ),
    );
    // O id criado pelo o firebase tá vindo como 'name'
    final id = jsonDecode(response.body)['name'];
    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        date: date,
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }
}
