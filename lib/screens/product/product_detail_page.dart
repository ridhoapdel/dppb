import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/styles/theme.dart';
import '../../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist_items') ?? [];
    setState(() {
      _isFavorite = wishlist.contains(widget.product.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist_items') ?? [];

    if (wishlist.contains(widget.product.id)) {
      wishlist.remove(widget.product.id);
      setState(() {
        _isFavorite = false;
      });
    } else {
      wishlist.add(widget.product.id);
      setState(() {
        _isFavorite = true;
      });
    }

    await prefs.setStringList('wishlist_items', wishlist);
  }

  Future<void> _addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList('cart_items') ?? [];

    // Check if item already in cart
    var cartItem = cartJson.firstWhere(
      (item) => jsonDecode(item)['id'] == widget.product.id,
      orElse: () => '',
    );

    if (cartItem.isNotEmpty) {
      // Update quantity
      final item = jsonDecode(cartItem) as Map<String, dynamic>;
      item['qty'] = (item['qty'] as int) + 1;
      cartJson.remove(cartItem);
      cartJson.add(jsonEncode(item));
    } else {
      // Add new item
      cartJson.add(jsonEncode({
        'id': widget.product.id,
        'qty': 1,
      }));
    }

    await prefs.setStringList('cart_items', cartJson);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk ditambahkan ke keranjang!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Carousel using PageView
            SizedBox(
              height: 300,
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _imageIndex = index;
                  });
                },
                itemCount: widget.product.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.dividerColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.product.images.isNotEmpty && index < widget.product.images.length
                            ? widget.product.images[index]
                            : widget.product.images.isNotEmpty
                                ? widget.product.images[0]
                                : 'assets/img/product1_1.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 80,
                            color: AppTheme.secondaryColor,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Image Indicators
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.product.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _imageIndex == index
                          ? AppTheme.accentColor
                          : AppTheme.dividerColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Price
                  Text(
                    AppTheme.formatPrice(widget.product.price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 1,
                    color: AppTheme.dividerColor,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      // Wishlist Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                _isFavorite ? Colors.red : AppTheme.accentColor,
                          ),
                          label: const Text('Wishlist'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentColor,
                            side: const BorderSide(
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add to Cart Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
