import 'package:flutter/material.dart';
import 'package:bullionprod/model/customer_purchase_model.dart';

import 'package:bullionprod/service/customer_purchase_service.dart';
import 'package:bullionprod/widget/purchase_item_widget.dart';

class PurchaseItemScreen extends StatefulWidget {
  const PurchaseItemScreen({super.key});

  @override
  State<PurchaseItemScreen> createState() => _PurchaseItemState();
}

class _PurchaseItemState extends State<PurchaseItemScreen> {
  List<CustomerPurchaseModel> allPurchase = [];
  @override
  void initState() {
    super.initState();
    _loadItems(); // Call the method to load items when the screen initializes
  }

  void _loadItems() {
    int customerId = 12;

    final customerPurchase = CustomerPurchaseService();
    customerPurchase.getAllPurchase(customerId).then((value) {
      if (!mounted) return;
      setState(() {
        allPurchase = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Purchase',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            //Text(formatDate, style: TextStyle(fontSize: 13))
            // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            //   Text(formatDate, style: TextStyle(fontSize: 13)),
            // ])
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[300], // Set the background color of the Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Weight',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Price',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Commodity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Date',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(), // Optional divider between header and list
            // ListView for items
            Expanded(
              child: ListView.builder(
                itemCount: allPurchase
                    .length, // Replace with the actual number of items
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 2.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [PurchaseItemWidget(allPurchase[index])],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
