import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:shop/exceptions/htttp_exceptions.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  String _token;
  String _userId;
  List<Product> _items = [];

  bool _showFavoriteOnly = false;
  List<Product> get items {
    if (_showFavoriteOnly) {
      return _items.where((prod) => prod.isFavorite).toList();
    }
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  ProductList([
    this._token = '',
    this._userId = '',
    this._items = const [],
  ]);

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'),
    );

    if (response.body == 'null') return;

    final favoriteResponse = await http.get(
      Uri.parse(
        '${Constants.USER_FAVORITES_URL}/$_userId.json?auth=$_token',
      ),
    );

    Map<String, dynamic> favoriteData = favoriteResponse.body == 'null'
        ? {}
        : jsonDecode(favoriteResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    print(data);
    data.forEach((productId, productData) {
      final isFavorite = favoriteData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['ImageUrl'],
          isFavorite: isFavorite,
        ),
      );
      notifyListeners();
    });
  }

  void showFavoriteOnly() {
    _showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoriteOnly = false;
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: double.parse(data['price'].toString()),
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  /* Usando o método then
  Future<void> addProduct(Product product) {
    final future = http.post(
      Uri.parse('$_baseUrl/products'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "ImageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        },
      ),
    );
    return future.then<void>((resp) {
      final id = jsonDecode(resp.body)['name'];
      _items.add(Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    });
  }
  */
// Usando o Async/Await
  Future<void> addProduct(Product product) async {
    final future = await http.post(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "ImageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(future.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "ImageUrl": product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
            msg: 'Não foi possível excluir esse produto',
            statusCode: response.statusCode);
      }
    }
  }
}
// ChangeNotifier é quem avisa sobre determinado evento a todos os "interessados".