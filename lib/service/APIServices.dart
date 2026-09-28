import 'dart:convert';

import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CategoryModel.dart';
import 'package:bullionprod/model/CommodityRateModel.dart';
import 'package:bullionprod/model/CusomerSignupModel.dart';
import 'package:bullionprod/model/CustomerLoginModel.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/model/ProductSearchCriteria.dart';
import 'package:bullionprod/model/SubCategoryModel.dart';
import 'package:bullionprod/model/customer_purchase_model.dart';
import 'package:bullionprod/service/ApiClient.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  final ApiClient _client = ApiClient();
  final Logger logger = Logger();

  List<CategoryModel>? _cachedCategories;
  List<ProductModel>? _cachedProduct;

  Future<List<ProductModel>> getAllProductCached({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProduct != null && _cachedProduct!.isNotEmpty) {
      logger.d('ProductService: returning cached products (${_cachedProduct!.length})');
      return _cachedProduct!;
    }

    final fetched = await gerAllProducts();
    _cachedProduct = fetched;
    logger.d('ProductService: cached ${_cachedProduct?.length ?? 0} product');
    return fetched;
  }

  /// Returns cached categories if available, otherwise fetches from server and caches them.
  Future<List<CategoryModel>> getAllCategoryCached({
    bool forceRefresh = false,
    required int? commodityId,
  }) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      logger.d('ProductService: returning cached categories (${_cachedCategories!.length})');
      return _cachedCategories!;
    }

    final fetched = await getAllCategory(commodityId);
    _cachedCategories = fetched;
    logger.d('ProductService: cached ${_cachedCategories?.length ?? 0} categories');
    return fetched;
  }

  Future<List<ProductModel>> gerAllProducts() async {
    try {
      List<ProductModel> allProductss = [];
      String url = AppConfig.GET_PRODUCTS_DIO;

      final response = await _client.dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to getCustomerId: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<CategoryModel>> getAllCategory(int? commodityId) async {
    List<CategoryModel> allCategories = [];
    try {
      String url = AppConfig.GET_CATEGORY_DIO;
      logger.d('Fetching categories from URL: $url');
      String body = jsonEncode(commodityId);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to getCustomerId: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
    return allCategories;
  }

  Future<List<ProductModel>> loadProdBySearchCriteria(
    Productsearchcriteria productsearchcriteria,
  ) async {
    try {
      String url = AppConfig.SEARCH_PRODUCT_DIO;
      logger.d('Fetching loadProdBySearchCriteria from URL: $url');
      String body = jsonEncode(productsearchcriteria);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to loadProdBySearchCriteria: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  /**
   *
   */
  Future<List<SubCategoryModel>> loadSubCategories(int categoryId) async {
    try {
      String url = AppConfig.GET_SUBCATEGORY_DIO;
      logger.d('Fetching loadSubCategories from URL: $url');
      String body = jsonEncode(categoryId);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => SubCategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to loadSubCategories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<ProductModel>> getAllProductsBySubCatId(int subcatId) async {
    try {

      String url = AppConfig.GET_PRODUCT_DIO;

      String body = jsonEncode(subcatId);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to getAllProductsBySubCatId: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<int?> getCustomerId(Customerloginmodel loginModel) async {
    int? customerId = -1;

    final url = AppConfig.CUSTOMER_LOGIN_DIO;
    try {
      String body = jsonEncode(loginModel);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        // Try to parse integer from body or from a JSON field named 'customerId' or 'id'
        final raw = response.data;
        if (raw is int) {
          customerId = raw;
        }
        return customerId;
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<int?> customerSignUp(CustomerSignup loginModel) async {
    int? customerId = -1;

    final url = AppConfig.CUSTOMER_SIGNUP_DIO;
    try {
      String body = jsonEncode(loginModel);
      final response = await _client.dio.post(url, data: body);

      if (response.statusCode == 200) {
        // Try to parse integer from body or from a JSON field named 'customerId' or 'id'
        final raw = response.data;
        if (raw is int) {
          customerId = raw;
        }
        return customerId;
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<CommodityRateModel?> getCommodityRate() async {
    String url = AppConfig.GET_COMMODITY_RATE_DIO;
    try {
      final response = await _client.dio.get(url);

      if (response.statusCode == 200) {
        final raw = response.data;

        // if (raw is CommodityRateModel) {
        //   return raw;
        // }

        if (raw is Map) {
          return CommodityRateModel.fromJson(Map<String, dynamic>.from(raw));
        }

        if (raw is List && raw.isNotEmpty && raw.first is Map) {
          return CommodityRateModel.fromJson(Map<String, dynamic>.from(raw.first));
        }

        return null;
      }
    } on DioException catch (e) {
      print(e.stackTrace);
      throw Exception('Network error: ${e.message}');
    }
    return null;
  }
}
