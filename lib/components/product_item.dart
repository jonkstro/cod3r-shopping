import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final items = cart.items.values.toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              onPressed: () {
                product.toggleFavorite();
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          trailing: Consumer<Cart>(
            builder: (ctx, cart, _) => IconButton(
              onPressed: () {
                cart.addItem(product);
              },
              // icon: const Icon(Icons.shopping_cart),
              icon: cart.getItemQtd(product.id) > 0
                  ? Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          constraints:
                              const BoxConstraints(minHeight: 16, minWidth: 16),
                          child: Text(
                            textAlign: TextAlign.center,
                            cart.getItemQtd(product.id).toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.shopping_cart_outlined),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productDetail,
              arguments: product,
            );
          },
        ),
      ),
    );
  }
}
