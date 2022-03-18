// Esse será o componente que representará cada elemento do meu GridView

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/models/cart.dart';

import 'package:shop/utils/app_routes.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover, // Imagem cobre o elemento inteiro
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.PRODUCT_DETAIL,
              arguments: product,
            );
          },
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              color: Colors.amber,
              onPressed: () {
                product.toggleFavorite(auth.token ?? '', auth.userId ?? '');
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
            ),
          ), // o Consumer tem a mesma serventia que o Provider, porém consigo usar ele em treichos pequenos, como no exemplo acima. Ele tem um builder com 3 pametros, o ctx, o Provider e um child que eu queira mostrar, como por exemplo um texto ou algo do tipo. Ao invés de renderizar todo o material dentro do provider ele irá redenrizar somente o elemento escolhido pelo consumer.
          // GridTileBar é a barra escura (escura pq defini uma cor no backgroud) em cada elemento do grid. Footer é rodapé.
          backgroundColor: Colors.black87,
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                //ScaffolMessenger mostrará um alerta no rodapé com as informações passadas nos parâmetros,
                //content com o Text da mensagem, duration com a duração dessa mensagem, action com uma label (texto pressionável)
                // e uma função onpressed que fará alguma coisa.
                SnackBar(
                  content: const Text('Produto adicionado com sucesso!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
              print(cart.itemsCount);
            },
          ),
        ),
      ),
    ); // cortaa borda do elemento da forma que for selecionada no borderRadius.
  }
}
