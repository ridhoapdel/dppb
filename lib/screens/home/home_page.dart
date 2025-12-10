import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/styles/theme.dart';
import '../../models/product.dart';
import '../../repository/product_repository.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductRepository _repository = ProductRepository();
  List<Product> _products = [];
  List<String> _wishlist = [];
  bool _isLoading = true;
  int _carouselIndex = 0;

  final List<String> _bannerImages = [
    'assets/img/1.jpg',
    'assets/img/2.jpg',
    'assets/img/3.jpg',
  ];

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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          'Laviade',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel Banner using PageView
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _carouselIndex = index;
                        });
                      },
                      itemCount: _bannerImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.dividerColor,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _bannerImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: AppTheme.secondaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Carousel Indicators
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _bannerImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _carouselIndex == index
                                ? AppTheme.accentColor
                                : AppTheme.dividerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Best Selling Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Best Selling',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final isFavorite =
                                _wishlist.contains(product.id);
                            return ProductCard(
                              product: product,
                              onTap: () => _navigateToProductDetail(product),
                              onFavorite: () =>
                                  _toggleWishlist(product.id),
                              isFavorite: isFavorite,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shop Now CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/product_list'),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Shop Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
