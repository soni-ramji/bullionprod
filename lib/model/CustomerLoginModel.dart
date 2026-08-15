import 'dart:convert';

class Customerloginmodel {
  final String username;
  final String password;

  Customerloginmodel({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}