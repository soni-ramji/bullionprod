import 'dart:math';

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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          logger.d('Selected index: $index');
          setState(() => _selectedNavIndex = index);
          if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            label: 'COLLECTION',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'SEARCH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'WISHLIST',
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
    return _buildBottomNavBar();
  }
}
