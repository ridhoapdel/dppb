import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/styles/theme.dart';
import 'models/product.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/product/product_detail_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/cart/cart_page.dart';
import 'screens/cart/checkout_page.dart';
import 'screens/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laviade App',
      theme: AppTheme.lightTheme,
      initialRoute: isLoggedIn ? '/main_nav' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main_nav': (context) => const MainNavigationPage(),
        '/home': (context) => const MainNavigationPage(),
        '/product_list': (context) => const MainNavigationPage(initialIndex: 1),
        '/wishlist': (context) => const MainNavigationPage(initialIndex: 2),
        '/profile': (context) => const ProfilePage(),
        '/product_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Product) {
            return ProductDetailPage(product: args);
          }
          return const MainNavigationPage();
        },
        '/cart': (context) => const CartPage(),
        '/checkout': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final totalPrice = (args is int) ? args : 0;
          return CheckoutPage(totalPrice: totalPrice);
        },
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
    );
  }
}

