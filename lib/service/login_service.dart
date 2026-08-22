import 'dart:convert';

import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CusomerSignupModel.dart';
import 'package:bullionprod/model/CustomerLoginModel.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';

class LoginService {
  final Logger logger = Logger();
  int customerId = -1;
  Future<int?> getCustomerId(Customerloginmodel loginModel, {Duration timeout = const Duration(seconds: 15)}) async {
    final url = Uri.parse(AppConfig.CUSTOMER_LOGIN);
    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': loginModel.username,
          'password': loginModel.password
        }),
      )
          .timeout(timeout);

      if (response.statusCode == 200) {
        // Try to parse integer from body or from a JSON field named 'customerId' or 'id'
        try {
          final decoded = jsonDecode(response.body);
          logger.d('Response data: $decoded');
          if (decoded is int) {
            customerId = decoded;
            return customerId;
          } else if (decoded is Map && (decoded['customerId'] != null || decoded['id'] != null)) {
            final val = decoded['customerId'] ?? decoded['id'];
            customerId = int.tryParse(val.toString()) ?? -1;
            return customerId;
          }
        } catch (_) {
          // fallback: try parsing raw body as int
          try {
            customerId = int.parse(response.body.trim());
            return customerId;
          } catch (e) {
            logger.e('Failed to parse customer id from response: $e');
            return null;
          }
        }
      } else {
        logger.e('Failed to fetch customer ID. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error occurred while fetching customer ID: $e');
      return null;
    }
  }

  /**
   *
   */
  Future<int?> signup(CustomerSignup customersignup) async {
    int customerId = -1;
    final url = Uri.parse(
        AppConfig.CUSTOMER_SIGNUP
    ); // Replace with your API endpoint

    var request = jsonEncode({
      'id':-1,
      'name': customersignup.name,
      'tradename': customersignup.tradename,
      'type': customersignup.type,
      'mobileno': customersignup.mobileno,
      'typename': customersignup.typename,
      'address': null,
      'identitytype': customersignup.identitytype,
      'identityvalue': customersignup.identityvalue,
      'passwd': customersignup.passwd
    });
    logger.d('URL is : $url');
    logger.d('Sending signup request: $request');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: request,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Response data: $data');
        customerId = int.parse(response.body);
        return customerId; // Adjust the key based on your API response
      } else {
        logger.e(
          'Failed to fetch customer ID. Status code: ${response.statusCode}',
        );
        return customerId;
      }
    } catch (e) {
      logger.e('Error occurred while fetching customer ID: $e');
      return customerId;
    }
  }

  int getSelectedCustomerId() {
    return customerId;
  }
}
