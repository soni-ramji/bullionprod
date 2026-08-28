import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarStless extends StatelessWidget implements PreferredSizeWidget {
  const AppBarStless({super.key, required this.title});
  final String title;

  // @override
  // Size get preferredSize => const Size.fromHeight(50.0);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title),
      backgroundColor: Colors.deepPurple,
      elevation: 4.0, // Controls shadow depth
      centerTitle: true,
    );
  }


}
