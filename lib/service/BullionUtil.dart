import 'dart:convert';

import 'package:bullionprod/app_scaffold_messenger.dart';
import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BullionUtil{

  static void showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = AppScaffoldMessenger.key.currentState;
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    });
  }

  static String  readString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '-';
  }

  static String readImageUrl(Map<String, dynamic> item) {
    final imagePathValue = item['imagepath'];
    if (imagePathValue is List) {
      for (final raw in imagePathValue) {
        final candidate = raw?.toString().trim() ?? '';
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    } else if (imagePathValue is String && imagePathValue.trim().isNotEmpty) {
      return imagePathValue.trim();
    }

    final directUrl = BullionUtil.readString(item, [
      'imageUrl',
      'imagename',
      'image',
      'url',
    ]);
    if (directUrl != '-' && directUrl.trim().isNotEmpty) {
      return directUrl;
    }

    final imageMap =
        item['subcatimages'] ?? item['catimages'] ?? item['images'];
    if (imageMap is Map) {
      final map = Map<String, dynamic>.from(imageMap);

      final nestedImagePath = map['imagepath'];
      if (nestedImagePath is List) {
        for (final raw in nestedImagePath) {
          final candidate = raw?.toString().trim() ?? '';
          if (candidate.isNotEmpty) {
            return candidate;
          }
        }
      } else if (nestedImagePath is String &&
          nestedImagePath.trim().isNotEmpty) {
        return nestedImagePath.trim();
      }

      final mappedUrl = BullionUtil.readString(map, [
        'url',
        'imageUrl',
        'path',
        'filename',
      ]);
      if (mappedUrl != '-' && mappedUrl.trim().isNotEmpty) {
        return mappedUrl;
      }
    }

    return '';
  }

  // static double readDouble(Map<String, dynamic> item, List<String> keys) {
  //   for (final key in keys) {
  //     final value = item[key];
  //     if (value == null) continue;
  //     if (value is num) return value.toDouble();
  //     final parsed = double.tryParse(value.toString());
  //     if (parsed != null) return parsed;
  //   }
  //   return 0;
  // }


  static double readDouble(Map<String, dynamic> json, String fieldName) {
    double intValue = 0.0;
    if (json[fieldName] != null) {
      if (json[fieldName] is double)
        intValue = json[fieldName] as double;
      else
        intValue = double.tryParse(json[fieldName].toString()) ?? 0;
    }
    return intValue;
  }
  static int readInt(Map<String, dynamic> json,String fieldName){
    int intValue = 0;
    if (json[fieldName] != null) {
      if (json[fieldName] is int)
        intValue = json[fieldName] as int;
      else
        intValue = int.tryParse(json[fieldName].toString()) ?? 0;
    }
    return intValue;
  }

  static String readStringValue(Map<String, dynamic> json, String fieldName) {


    return json[fieldName]?.toString() ??'';

  }

  static bool readBool(Map<String, dynamic> json,String fieldName){
    bool isBool = false;
    if (json[fieldName] != null) {
      if (json[fieldName] is bool)
        isBool = json[fieldName] as bool;
      else
        isBool = bool.tryParse(json[fieldName].toString()) ?? false;
    }
    return isBool;
  }

  static List<String> readListStringValue(Map<String, dynamic> json, String fieldName) {
    List<String> imagepath;

    if (json[fieldName] != null && json[fieldName] is List) {
      imagepath = List<String>.from(json[fieldName]);
    } else {
      imagepath = [];
    }
  return imagepath;
  }

   static void toggleFavourite(ProductModel product, AppShoppingState _shoppingState) {
    _shoppingState.toggleFavourite(product);
  }

}