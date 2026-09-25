import 'package:bullionprod/model/ProductModel.dart';
import 'package:flutter/foundation.dart';

/// Shared favourites and shopping-cart state for the entire app session.
class AppShoppingState extends ChangeNotifier {
  AppShoppingState._();

  static final AppShoppingState instance = AppShoppingState._();

  final List<ProductModel> _favourites = [];
  final  List<ProductModel> _cart = [];

  List<ProductModel> get favourites => List.unmodifiable(_favourites);
  List<ProductModel> get cart => List.unmodifiable(_cart);
  int get favouriteCount => _favourites.length;
  int get cartCount => _cart.length;

  String keyFor(ProductModel product) {
    final id = product.id ?? '';
    final name = product.prodname;
    return '$id|$name';
  }

  bool isFavourite(ProductModel product) {
    final key = keyFor(product);
    return _favourites.any((item) => keyFor(product) == key);
  }

  void toggleFavourite(ProductModel product) {
    final key = keyFor(product);
    final index = _favourites.indexWhere((item) => keyFor(product) == key);
    if (index >= 0) {
      _favourites.removeAt(index);
    } else {
      _favourites.add(product);
    }
    notifyListeners();
  }

  void addToCart(ProductModel product) {
    final key = keyFor(product);
    if (_cart.any((item) => keyFor(item) == key)) return;
    _cart.add(product);
    notifyListeners();
  }
}
