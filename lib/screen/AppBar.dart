import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:bullionprod/screen/login_screen.dart';
import 'package:bullionprod/widget/circular_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appbar extends StatefulWidget {
  const Appbar({super.key});

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  final AppShoppingState _shoppingState = AppShoppingState.instance;
  final GlobalKey _productsSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _buildAppBar();
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5C4300),
      foregroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: _openMainMenu,
      ),
      title: Column(
        children: [
          const Text(
            'THE TD',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'JEWELS',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                _shoppingState.favouriteCount > 0
                    ? Icons.favorite
                    : Icons.favorite_outline,
                color: Colors.white,
              ),
              onPressed: _openFavouriteList,
            ),
            if (_shoppingState.favouriteCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_shoppingState.favouriteCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
              onPressed: _openCartList,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _shoppingState.cartCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }
  void _openMainMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Main menu',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final halfHeight = MediaQuery.of(dialogContext).size.height * 0.4;
        final halfwidth = MediaQuery.of(dialogContext).size.width * 0.5;
        return SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: const Color(0xFFD4AF37),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: SizedBox(
                width: halfwidth,
                height: halfHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined),
                        title: const Text('Contact Us'),
                        subtitle: const Text('Get help from our team'),
                        onTap: () {
                          // Navigator.of(dialogContext).pop();
                          // _showContactUsDialog();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ContactUs()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on_outlined),
                        title: const Text('Gold Rate'),
                        subtitle: const Text('Jump to gold rate section'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Commodityrate()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Products'),
                        subtitle: const Text('Jump to products section'),
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _scrollToSection(_productsSectionKey);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
  void _scrollToSection(GlobalKey sectionKey) {
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      final sectionContext = sectionKey.currentContext;
      if (sectionContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    });
  }
  void _openFavouriteList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = _shoppingState.favourites;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Favourite Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                  child: Text(
                    'No favourites yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
                    : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    final imagePaths = product.imagepath;
                    final imageUrl =
                    imagePaths is List && imagePaths.isNotEmpty
                        ? imagePaths.first.toString()
                        : '';
                    return ListTile(
                      leading: CircularNetworkImage(url: imageUrl, size: 44),
                      title: Text(
                        product.prodname.toString() ?? 'Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${product.prodweight ?? '-'} gm',
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            _shoppingState.toggleFavourite(product),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customerId');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _openCartList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = _shoppingState.cart;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: items.isEmpty
              ? const Center(child: Text('No products in cart.'))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final price = double.tryParse(
                  item.productprice.toString() ?? '') ??
                  0;
              return ListTile(
                title: Text(item.prodname.toString() ?? 'Product'),
                subtitle: Text(
                  '₹ ${price.toStringAsFixed(2)}',
                ),
                trailing: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFFD4AF37),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
