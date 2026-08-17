import 'dart:convert';

import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CusomerSignupModel.dart';
import 'package:bullionprod/model/CustomerLoginModel.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';

class LoginService {
  final Logger logger = Logger();
  int customerId = -1;
  Future<int?> getCustomerId(Customerloginmodel loginModel) async {
    final url = Uri.parse(
     AppConfig.CUSTOMER_LOGIN
    ); // Replace with your API endpoint
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': loginModel.username,
          'password': loginModel.password
        }),
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
