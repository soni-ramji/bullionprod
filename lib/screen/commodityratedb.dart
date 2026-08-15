import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/commoditymodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class comodityratedb extends StatefulWidget {
  const comodityratedb({super.key});

  @override
  State<comodityratedb> createState() => _comodityratedbState();
}

class _comodityratedbState extends State<comodityratedb> {

 List<commoditymodel> allcommodity= [];

  @override
  void initState() {
    super.initState();
    getallcommodityrate();
  }

  Future<void> getallcommodityrate() async {
    try {
      List<commoditymodel> allCategories = [];
      String url = AppConfig.GET_COMMODITY_RATE;
      log('Fetching categories from URL: $url');
      //final SharedPreferences prefs = await SharedPreferences.getInstance();
      int commodityId = 1; //prefs.getInt('commodityId') ?? 0;
      String body = jsonEncode(commodityId);
      final response = await http
          .get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        //body: body,
      )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        log("response body: ${response.body}");
        List<dynamic> listItem = [];

        if (decoded is List) {
          listItem = decoded;
        } else if (decoded is Map) {
          // Common wrapper keys that may contain the list
          if (decoded['data'] is List) {
            listItem = decoded['data'];
          } else if (decoded['items'] is List) {
            listItem = decoded['items'];
          } else if (decoded['result'] is List) {
            listItem = decoded['result'];
          } else if (decoded['list'] is List) {
            listItem = decoded['list'];
          } else {
            // Fallback: convert map values to a list (handles numeric-keyed objects)
            listItem = decoded.values.toList();
          }
        } else {
          log('Unexpected JSON type: ${decoded.runtimeType}');
        }

        log('parsed listItem length: ${listItem.length}');

        for (final rawItem in listItem) {
          if (rawItem == null) continue;
          Map<String, dynamic> item;
          try {
            item = Map<String, dynamic>.from(rawItem as Map);
          } catch (e) {
            // Skip non-map items
            continue;
          }

          int id = 0;
          String catname = '';
          bool isactive = false;
          int commodityId = 0;
          String commodityName = '';
          String description = '';
          Map<String, String>? catimages;
          // Safely read fields with type checks
          if (item['id'] != null) {
            id = (item['id'] is int)
                ? item['id'] as int
                : int.tryParse(item['id'].toString()) ?? 0;
          }

          if (item['commodityName'] != null) {
            commodityName = item['commodityName'].toString();
          }


          commoditymodel categoryModel = commoditymodel(
            id: id,

            commodityName: commodityName,

          );

          allCategories.add(categoryModel);
        }

        if (!mounted) return;
        setState(() {
          allcommodity = allCategories;
          // _stockImageUrls
          //   ..clear()
          //   ..addAll(imageMap);
          log('allCategories is ${allCategories.length}');
        });
      } else {
        // _showErrorSnackBar(
        //   'Unable to load categories. Server error (${response.statusCode}).',
        // );
      }
    } on TimeoutException catch (e) {
      log('TimeoutException: $e');
     // _showErrorSnackBar('Server is down or not responding. Please try again.');
    } on SocketException catch (e) {
      log('SocketException: $e ');
     // _showErrorSnackBar('Network is down. Please check internet connection.');
    } on http.ClientException  catch (e){
     // _showErrorSnackBar('Cannot connect to server. Please check network.');
      log('ClientException: $e');
    } catch (e) {
      //_showErrorSnackBar('Server is down. Please try again later.');
      log('getAllCategories error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Text("my Name is Ram ji ");

  }
}
