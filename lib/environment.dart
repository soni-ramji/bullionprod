// Centralized environment configuration.
// Use `--dart-define=ENV=prod` when building for production.

class AppConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

   //static const String _devBase = 'http://192.168.0.2:8090/bullionadmin';
   static const String _prodBase = 'http://192.168.29.140:8090/bullionadmin';
   static const String _devBase = 'https://c48pz40q74.execute-api.us-east-1.amazonaws.com/dev';
  // static const String _prodBase = 'http://127.0.0.1:8086/bullionadmin';

  static String get baseUrl => env == 'prod' ? _prodBase : _devBase;

  // Endpoints
  static String get GET_CATEGORY => '$baseUrl/category/getcategories';
  static String get GET_SUBCATEGORY =>
      '$baseUrl/subcategory/getsubcategoriesbycatid';
  static String get CUSTOMER_LOGIN => '$baseUrl/customer/getmobilecustomer';

  static String get CUSTOMER_SIGNUP => '$baseUrl/customer/addmobilecustomer';
  static String get GET_STOCK => '$baseUrl/stockswithmrp';
  static String get SAVE_ORDER => '$baseUrl/order/saveorder';
  static String get GET_CUSTOMER_ORDERS => '$baseUrl/order/getorderbycustid';
  static String get GET_ORDER_DETAILS =>
      '$baseUrl/order/getorderdetailsbyorderid';
  static String get GET_PRODUCTS => '$baseUrl/tdproduct/listallformobile';
  static String get GET_PRODUCT => '$baseUrl/tdproduct/list';

  static String get GET_COMMODITY_RATE => '$baseUrl/commodity/getcommoditiesrate';


}
