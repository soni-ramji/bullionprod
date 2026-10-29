import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/screen/RateCalculator.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:bullionprod/screen/home.dart';
import 'package:bullionprod/screen/home1.dart';
import 'package:bullionprod/screen/login_screen.dart';
import 'package:bullionprod/screen/thankyou.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Bottombar extends StatefulWidget {
  final int selectedIndex;

  const Bottombar({super.key, this.selectedIndex = 0});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  late int _selectedNavIndex;
  final AppShoppingState _shoppingState = AppShoppingState.instance;

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = widget.selectedIndex;
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            final items = _shoppingState.cart;
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
                    'Cart Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              'No products in cart.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final price =
                                  double.tryParse(item.productprice.toString()) ?? 0;
                              return ListTile(
                                title: Text(item.prodname.toString()),
                                subtitle: Text('₹ ${price.toStringAsFixed(2)}'),
                                trailing: IconButton(
                                  onPressed: () {
                                    _shoppingState.removeFromCart(item);
                                    setModalState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: items.isEmpty
                            ? null
                            : () {
                          _shoppingState.clearCart();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cart submitted successfully.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ThankYou()),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C4300),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    const selectedColor = Color(0xFFD4AF37);
    const unselectedColor = Color(0xFF9E9E9E);

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
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        selectedIconTheme: const IconThemeData(color: selectedColor, size: 22),
        unselectedIconTheme: const IconThemeData(color: unselectedColor, size: 22),
        selectedLabelStyle: const TextStyle(fontSize: 9, color: selectedColor),
        unselectedLabelStyle: const TextStyle(fontSize: 9, color: unselectedColor),
        iconSize: 22,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        enableFeedback: false,
        showSelectedLabels: true,
        showUnselectedLabels: true,
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

          else if (index == 6) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Ratecalculator()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined),
            activeIcon: const Icon(Icons.trending_up),
            label: 'Live Rate',
          ),
          BottomNavigationBarItem(
            icon: _buildCartNavIcon(selected: false),
            activeIcon: _buildCartNavIcon(selected: true),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: 'WISHLIST',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            activeIcon: const Icon(Icons.location_on),
            label: 'Contact US',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            activeIcon: const Icon(Icons.account_circle),
            label: 'ACCOUNT',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate_outlined),
            activeIcon: const Icon(Icons.calculate),
            label: 'Calculator',
          ),
        ],      ),
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
