// Centralized environment configuration.
// Use `--dart-define=ENV=prod` when building for production.
// Use `--dart-define=API_BASE_URL=http://10.0.2.2:8090/bullionadmin` to override the local backend.

// ignore_for_file: non_constant_identifier_names

class AppConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String _devBase = 'http://66.116.246.40:8090/bullionadmin';
  static const String _prodBase = 'http://localhost:8090/bullionadmin';

  static String get _overrideBaseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // static String get _platformDevBase {
  //  if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
  //  if (Platform.isAndroid) return 'http://66.116.246.40:8090/bullionadmin';
  //  if (Platform.isIOS) return 'http://127.0.0.1:8090/bullionadmin';
  //  return 'http://localhost:8090/bullionadmin';
  // }

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    return env == 'prod' ? _prodBase : _devBase;
  }

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

  static String get SEARCH_PRODUCT => '$baseUrl/tdproduct/listallbykeyword';


  static String get GET_PURCHASE_CUSTOMER => '/customermobile/getAllPurchaseByCustomerId';

  /////////////

  static String get GET_CATEGORY_DIO => '/category/getcategories';

  static String get GET_PRODUCTS_DIO => '/tdproduct/listallformobile';

  static String get SEARCH_PRODUCT_DIO => '/tdproduct/listallbykeyword';
  static String get GET_SUBCATEGORY_DIO =>
      '/subcategory/getsubcategoriesbycatid';

  static String get GET_PRODUCT_DIO => '/tdproduct/list';

  static String get CUSTOMER_LOGIN_DIO => '/customer/getmobilecustomer';

  static String get CUSTOMER_SIGNUP_DIO => '/customer/addmobilecustomer';

  static String get GET_COMMODITY_RATE_DIO => '/commodity/getcommoditiesrate';

  static String get CUSTOMER_CHANGE_PASSWORD_DIO => '/customer/chngpasswd';

  static String get CUSTOMERID=>'customerId';

  static String get GET_BANNER_IMAGES=>'/banner/getbanner';

}
