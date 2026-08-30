import 'package:flutter/material.dart';

class Frontwidget extends StatelessWidget {
  const Frontwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.home,
        size: 100,
        color: Colors.grey[400],
      )
    );
  }
}
