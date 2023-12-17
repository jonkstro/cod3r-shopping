import 'package:flutter/material.dart';
import 'package:minha_loja/components/product_item.dart';
import 'package:minha_loja/data/dummy_data.dart';

import '../models/product.dart';

class ProductsOverviewPage extends StatelessWidget {
  final List<Product> loadedProducts = DUMMY_PRODUCTS;
  ProductsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha loja'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        // Montar somente a quantidade de itens corretamente
        itemCount: loadedProducts.length,
        // Fazer o mapping dos elementos mockados pegando o titulo
        itemBuilder: (context, index) {
          return ProductItem(product: loadedProducts[index]);
        },
        // Exibir 2 elementos em cada linha
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // Proporção de altura x largura
          childAspectRatio: 3 / 2,
          // Espaçar os itens
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}
