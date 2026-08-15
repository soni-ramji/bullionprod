import 'package:bullionprod/model/customer_purchase_model.dart';
import 'package:flutter/material.dart';


class PurchaseItemWidget extends StatelessWidget {
  const PurchaseItemWidget(this.customerPurchaseModel, {super.key});

  final CustomerPurchaseModel customerPurchaseModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          customerPurchaseModel.purchaseItem,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        const SizedBox(width: 15),
        Text(
          customerPurchaseModel.weight.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        const SizedBox(width: 40),
        Text(
          customerPurchaseModel.purchaseAmount.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        const SizedBox(width: 40),
        Text(
          customerPurchaseModel.commodity,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        const SizedBox(width: 30),
        Text(
          customerPurchaseModel.purchaseDate,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        const Divider(
          color: Colors.black, // Divider color
          thickness: 5, // Divider thickness
          height: 20, // Space around the divider
        ),
      ],
    );
  }
}

//   @override
