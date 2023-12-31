import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget(this.cartItem, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).colorScheme.error,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      // Vai excluir ou não
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tem Certeza?'),
            content: const Text('Quer realmente remover item do carrinho?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Através do Navigator.pop vamos retornar o FUTURE que o confirmDismiss
                  // espera receber, com um false (user não quer remover, vai cancelar).
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Não'),
              ),
              // const Spacer(),
              TextButton(
                onPressed: () {
                  // Através do Navigator.pop vamos retornar o FUTURE que o confirmDismiss
                  // espera receber, com um true (quer realmente remover).
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Sim'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<Cart>(
          context,
          listen: false,
        ).removeItem(cartItem.productId);
      },
      child: Card(
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text(cartItem.price.toStringAsFixed(2)),
                ),
              ),
            ),
            title: Text(cartItem.name),
            subtitle: Text(
                'Total: R\$ ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
            trailing: Text('${cartItem.quantity}x'),
          ),
        ),
      ),
    );
  }
}
