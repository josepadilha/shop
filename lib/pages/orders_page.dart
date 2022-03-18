import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/componentes/app.drawer.dart';
import 'package:shop/componentes/order.dart';
import 'package:shop/models/order_list.dart';

class OrdersPage extends StatelessWidget {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      body: FutureBuilder(
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.error != null) {
              return Center(child: Text('Ocorreu um erro.'));
            } else {
              return Consumer<OrderList>(
                  builder: ((ctx, orders, child) => ListView.builder(
                        itemCount: orders.itemsCount,
                        itemBuilder: (ctx, i) =>
                            OrderWidget(order: orders.items[i]),
                      )));
            }
          },
          future: Provider.of<OrderList>(context, listen: false).loadOrders()),
      // _isLoading
      //?
      //:
      drawer: AppDrawer(),
    );
  }
}
