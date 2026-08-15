import 'dart:convert';

import 'package:bullionprod/model/customer_purchase_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';


class CustomerPurchaseService {
  final Logger logger = Logger();
  int customerId = 0;
  Future<List<CustomerPurchaseModel>> getAllPurchase(int customerId) async {
    List<CustomerPurchaseModel> allPurchase = [];
    final url = Uri.parse(
      'http://192.168.29.203:8083/customermobile/getAllPurchaseByCustomerId',
    ); // Replace with your API endpoint
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"customerId": customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Response data: $data');

        // Map the JSON response to a list of CustomerPurchaseModel
        allPurchase = (data as List)
            .map((item) => CustomerPurchaseModel.fromJson(item))
            .toList();

        return allPurchase;

        // Adjust the key based on your API response
      } else {
        logger.e(
          'Failed to fetch purchase items. Status code: ${response.statusCode}',
        );
        return allPurchase;
      }
    } catch (e) {
      logger.e('Error occurred while fetching purchase items: $e');
      return allPurchase;
    }
  }
}
