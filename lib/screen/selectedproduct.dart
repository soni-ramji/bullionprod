import 'package:flutter/material.dart';

class SelectedProduct extends StatefulWidget {
  const SelectedProduct({super.key});

  @override
  State<SelectedProduct> createState() => _SelectedProductState();
}

class _SelectedProductState extends State<SelectedProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Product'),
      ),
      body: const Center(
        child: Text('This is the Selected Product page.'),
      ),
    );
  }
}
