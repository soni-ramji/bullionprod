import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:bullionprod/screen/home.dart';
import 'package:bullionprod/screen/home1.dart';
import 'package:bullionprod/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int _selectedNavIndex = 0;
  final AppShoppingState _shoppingState = AppShoppingState.instance;

  @override
  void initState() {
    super.initState();

    _shoppingState.addListener(_onShoppingStateChanged);
  }

  @override
  void dispose() {
    _shoppingState.removeListener(_onShoppingStateChanged);

    super.dispose();
  }

  void _onShoppingStateChanged() {
    if (mounted) setState(() {});
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
                    final price =
                        double.tryParse(
                          item.productprice.toString() ?? '',
                        ) ??
                        0;
                    return ListTile(
                      title: Text(item.prodname.toString() ?? 'Product'),
                      subtitle: Text('₹ ${price.toStringAsFixed(2)}'),
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

  Widget _buildCartNavIcon({required bool selected}) {
    final iconColor = selected ? const Color(0xFFD4AF37) : Colors.grey[400]!;

    return SizedBox(
      width: 28,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.shopping_cart_outlined,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          if (_shoppingState.cartCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_shoppingState.cartCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF5C4300),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontSize: 9),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        iconSize: 20,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        enableFeedback: false,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        onTap: (index) {
          logger.d('Selected index: $index');
          setState(() => _selectedNavIndex = index);

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen1()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Commodityrate()),
            );
          } else if (index == 2) {
            _openCartList();
          } else if (index == 3) {
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUs()),
            );
          } else if (index == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Live Rate',
          ),
          BottomNavigationBarItem(
            icon: _buildCartNavIcon(selected: false),
            activeIcon: _buildCartNavIcon(selected: true),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'WISHLIST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_searching),
            label: 'Contact US',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5C4300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomNavBar(),

          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 0, right: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'THE TD Software : +91 8800634100',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     color: const Color(0xFF5C4300),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         _buildBottomNavBar(),
  //         Padding(
  //           padding: const EdgeInsets.only(bottom: 4, top: 2, right: 8),
  //           child: Align(
  //             alignment: Alignment.centerRight,
  //             child: Text(
  //               'THE TD Software : +91 8800634100',
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 fontSize: 9,
  //                 color: Color(0xFFD4AF37),
  //                 fontWeight: FontWeight.w600,
  //                 letterSpacing: 0.2,
  //               ),
  //               textAlign: TextAlign.right,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
