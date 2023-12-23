import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/product_item.dart';
import 'package:shop/models/product_list.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductList products = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: Text('text'),

        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ProductItem(product: products.items[index]),
                const Divider(),
              ],
            );
          },
        ),
      ),

      // Padding(
      //   padding: const EdgeInsets.all(8),
      //   child: ListView.builder(
      //     itemCount: 4,
      //     itemBuilder: (ctx, index) {
      //       const Text(
      //         'opa',
      //         style: TextStyle(color: Colors.black),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}