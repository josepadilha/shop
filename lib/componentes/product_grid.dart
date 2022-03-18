import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/componentes/products_grid_item.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(
      context,
      listen:
          true, // se eu colocar listen false, ele para de escutar as alterações do provider);
    );
    final List<Product> loadedProducts = provider.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: loadedProducts[index],
        child: ProductGridItem(),
      ), // ChangedNotifierProvider quer dizer que é um interessado em determidao evento.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2, // relação da altura vs largura.
        crossAxisSpacing:
            10, // espaçamento entre os elementos no eixo principal (tem o padrão do eixo de linha)
        mainAxisSpacing:
            10, //  espaçamento entre os elementos no eixo vertical (tem o padrão do eixo de coluna, pq o eixo principal está como linha)
      ), //SliverGridDelegateWithFixedCrossAxisCount define quantos elementos ele irá mostrar por linha (nesse caso é linha por causa do Cross Axis).
    );
  }
}
