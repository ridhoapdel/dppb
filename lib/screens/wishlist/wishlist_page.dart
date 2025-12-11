import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/styles/theme.dart';
import '../../models/product.dart';
import '../../repository/product_repository.dart';
import '../../widgets/product_tile.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final ProductRepository _repository = ProductRepository();
  List<Product> _wishlistProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistProducts();
  }

  Future<void> _loadWishlistProducts() async {
    try {
      final products = await _repository.loadProducts();
      final prefs = await SharedPreferences.getInstance();
      final wishlistIds = prefs.getStringList('wishlist_items') ?? [];

      final wishlist = products
          .where((product) => wishlistIds.contains(product.id))
          .toList();

      setState(() {
        _wishlistProducts = wishlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat wishlist')),
      );
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist_items') ?? [];
    wishlist.remove(productId);
    await prefs.setStringList('wishlist_items', wishlist);

    setState(() {
      _wishlistProducts.removeWhere((product) => product.id == productId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dihapus dari wishlist'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).pushNamed('/product_detail', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Wishlist'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _wishlistProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Wishlist Kosong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan produk ke wishlist Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final product = _wishlistProducts[index];
                    return ProductTile(
                      product: product,
                      onTap: () => _navigateToProductDetail(product),
                      onDelete: () => _removeFromWishlist(product.id),
                    );
                  },
                ),
    );
  }
}
