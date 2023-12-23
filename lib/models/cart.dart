import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: Random().nextDouble().toString(),
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    // Se não localizar o item que quer remover, faz nada
    if (!_items.containsKey(productId)) {
      return;
    } else {
      _items.remove(productId);
      notifyListeners();
    }
  }

  // Método para remover só 1 item do carrinho
  void removeSingleItem(String productId) {
    // Se não localizar o item que quer remover, faz nada
    if (!_items.containsKey(productId)) {
      return;
    } else {
      // Se conseguir localizar o item que quer remover e só tiver 1 item,
      //vai diminuir remover o item do carrinho.
      if (_items[productId]!.quantity == 1) {
        removeItem(productId);
      } else if (_items[productId]!.quantity > 1) {
        // Se conseguir localizar o item que quer remover,vai diminuir a qtd -1
        _items.update(
          productId,
          (existingItem) => CartItem(
            id: existingItem.id,
            productId: existingItem.productId,
            name: existingItem.name,
            quantity: existingItem.quantity - 1,
            price: existingItem.price,
          ),
        );
      }
    }
    // Atualizar aos interessados que estão "escutando" essa alteração
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  int getItemQtd(String productId) {
    return _items.containsKey(productId) ? _items[productId]?.quantity ?? 0 : 0;
  }
}
