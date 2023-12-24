import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.name),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                // Vou navegar pra tela de ProductFormPage passando um produto pra editar
                Navigator.of(context).pushNamed(
                  AppRoutes.product_form,
                  arguments: product,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Excluir Produto'),
                    content:
                        const Text('Quer realmente remover item do carrinho?'),
                    actions: [
                      TextButton(
                        child: const Text('Não'),
                        onPressed: () {
                          // Fechar a tela de popup voltando false.
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('Sim'),
                        onPressed: () {
                          // Fechar a tela de popup voltando true.
                          Navigator.of(ctx).pop(true);
                        },
                      ),
                    ],
                  ),
                ).then((value) {
                  // Se fechar o popup voltando true:
                  if (value == true) {
                    // Se for excluir vai chamar o removeProduct do provider
                    Provider.of<ProductList>(
                      context,
                      listen: false,
                    ).removeProduct(product);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
