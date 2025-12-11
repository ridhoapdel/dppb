import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/styles/theme.dart';
import '../../models/product.dart';
import '../../repository/product_repository.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ProductRepository _repository = ProductRepository();
  Map<String, Map<String, dynamic>> _cartItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final products = await _repository.loadProducts();
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getStringList('cart_items') ?? [];

      final cartItems = <String, Map<String, dynamic>>{};

      for (final itemJson in cartJson) {
        final item = jsonDecode(itemJson) as Map<String, dynamic>;
        final product =
            products.firstWhere((p) => p.id == item['id']);

        cartItems[product.id] = {
          'product': product,
          'qty': item['qty'] as int,
        };
      }

      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat keranjang')),
      );
    }
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      _removeFromCart(productId);
      return;
    }

    setState(() {
      _cartItems[productId]!['qty'] = quantity;
    });

    await _saveCartToPreferences();
  }

  Future<void> _removeFromCart(String productId) async {
    setState(() {
      _cartItems.remove(productId);
    });

    await _saveCartToPreferences();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dihapus dari keranjang'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveCartToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _cartItems.entries.map((entry) {
      return jsonEncode({
        'id': entry.key,
        'qty': entry.value['qty'],
      });
    }).toList();

    await prefs.setStringList('cart_items', cartJson);
  }

  int _calculateTotal() {
    int total = 0;
    _cartItems.forEach((_, item) {
      final product = item['product'] as Product;
      final qty = item['qty'] as int;
      total += product.price * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Keranjang'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Keranjang Kosong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan produk ke keranjang Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final productId = _cartItems.keys.toList()[index];
                          final item = _cartItems[productId]!;
                          final product = item['product'] as Product;
                          final qty = item['qty'] as int;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(color: AppTheme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                // Image placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppTheme.dividerColor,
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppTheme.formatPrice(product.price),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Quantity controls
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Material(
                                        color: AppTheme.dividerColor,
                                        child: InkWell(
                                          onTap: () {
                                            _updateQuantity(
                                              productId,
                                              qty + 1,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        qty.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Material(
                                        color: AppTheme.dividerColor,
                                        child: InkWell(
                                          onTap: () {
                                            _updateQuantity(
                                              productId,
                                              qty - 1,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                // Delete button
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _removeFromCart(productId);
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Total and Checkout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: AppTheme.dividerColor),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                              Text(
                                AppTheme.formatPrice(_calculateTotal()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/checkout',
                                  arguments: _calculateTotal(),
                                );
                              },
                              child: const Text('Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
