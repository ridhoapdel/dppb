import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/styles/theme.dart';
import '../../models/product.dart';
import '../../repository/product_repository.dart';
import '../../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductRepository _repository = ProductRepository();
  List<Product> _products = [];
  List<String> _wishlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadWishlist();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _repository.loadProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat produk')),
      );
    }
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wishlist = prefs.getStringList('wishlist_items') ?? [];
    });
  }

  Future<void> _toggleWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist_items') ?? [];

    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }

    await prefs.setStringList('wishlist_items', wishlist);
    setState(() {
      _wishlist = wishlist;
    });
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).pushNamed('/product_detail', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Produk'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final isFavorite = _wishlist.contains(product.id);
                  return ProductCard(
                    product: product,
                    onTap: () => _navigateToProductDetail(product),
                    onFavorite: () => _toggleWishlist(product.id),
                    isFavorite: isFavorite,
                  );
                },
              ),
            ),
    );
  }
}
