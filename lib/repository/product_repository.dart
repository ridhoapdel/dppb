import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/product.dart';

class ProductRepository {
  static List<Product> _products = [];
  static bool _isLoaded = false;

  // Load products from local JSON file
  Future<List<Product>> loadProducts() async {
    if (_isLoaded && _products.isNotEmpty) {
      return _products;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _products = jsonData
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
      return _products;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Get product by ID
  Product? getById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all loaded products
  List<Product> getAllProducts() {
    return _products;
  }
}
