import 'package:flutter/foundation.dart';

class CustomerChangePasswordModel {
  int? custId;
  String? oldPasswd;
  String? newPasswd;

  CustomerChangePasswordModel({this.custId, this.oldPasswd, this.newPasswd});

  Map<String, dynamic> toJson() {
    return {
      'custId': custId,
      'oldPasswd': oldPasswd,
      'newPasswd': newPasswd,
    };
  }

  factory CustomerChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return CustomerChangePasswordModel(
      custId: json['custId'] as int?,
      oldPasswd: json['oldPasswd'] as String?,
      newPasswd: json['newPassword'] as String?,
    );
  }
}