import 'package:flutter/foundation.dart';

/// Shared favourites and shopping-cart state for the entire app session.
class AppShoppingState extends ChangeNotifier {
  AppShoppingState._();

  static final AppShoppingState instance = AppShoppingState._();

  final List<Map<String, dynamic>> _favourites = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _cart = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get favourites => List.unmodifiable(_favourites);
  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);
  int get favouriteCount => _favourites.length;
  int get cartCount => _cart.length;

  String keyFor(Map<String, dynamic> product) {
    final id = product['id']?.toString().trim() ?? '';
    final name = (product['prodname'] ?? product['productname'] ?? product['name'])
            ?.toString()
            .trim() ??
        '';
    return '$id|$name';
  }

  bool isFavourite(Map<String, dynamic> product) {
    final key = keyFor(product);
    return _favourites.any((item) => keyFor(item) == key);
  }

  void toggleFavourite(Map<String, dynamic> product) {
    final key = keyFor(product);
    final index = _favourites.indexWhere((item) => keyFor(item) == key);
    if (index >= 0) {
      _favourites.removeAt(index);
    } else {
      _favourites.add(Map<String, dynamic>.from(product));
    }
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    final key = keyFor(product);
    if (_cart.any((item) => keyFor(item) == key)) return;
    _cart.add(Map<String, dynamic>.from(product));
    notifyListeners();
  }
}
