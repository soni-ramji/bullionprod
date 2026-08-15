import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/app_scaffold_messenger.dart';
import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CategoryModel.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:bullionprod/screen/subcategory.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductModel> allproducts = [];
  List<ProductModel> filteredProducts = [];
  final AppShoppingState _shoppingState = AppShoppingState.instance;
  List<CategoryModel> allcategories = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categorySectionKey = GlobalKey();
  final GlobalKey _productsSectionKey = GlobalKey();
  int _currentBannerIndex = 0;
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _shoppingState.addListener(_onShoppingStateChanged);
    getAllCategory();
    gerAllProducts();
  }

  @override
  void dispose() {
    _shoppingState.removeListener(_onShoppingStateChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onShoppingStateChanged() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _productData(ProductModel product) => <String, dynamic>{
    'id': product.id,
    'prodname': product.prodname,
    'prodweight': product.prodweight,
    'karatpurity': product.karatpurity,
    'productprice': product.productprice,
    'imagepath': product.imagepath,
  };

  String _readString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  Future<void> gerAllProducts() async {
    try {
      List<ProductModel> allProductss = [];
      String url = AppConfig.GET_PRODUCTS;

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
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

          String prodname;
          double prodweight = 0.0;
          double karatpurity = 0.0;
          String searchtext = '';

          List<String> imagepath;
          // Safely read fields with type checks
          if (item['id'] != null) {
            id = (item['id'] is int)
                ? item['id'] as int
                : int.tryParse(item['id'].toString()) ?? 0;
            log('Parsed ProductModel id: $id');
          }
          prodname = _readString(
              item, ['prodname', 'prodname', 'categoryName', 'name']);
          log('Parsed ProductModel prodname: $prodname');
          searchtext = _readString(
              item, ['searchtext', 'searchtext', 'categoryName', 'name']);
          if (item['prodweight'] != null) {
            prodweight = (item['prodweight'] is double)
                ? item['prodweight'] as double
                : double.tryParse(item['prodweight'].toString()) ?? 0.0;
          }
          if (item['karatpurity'] != null) {
            karatpurity = (item['karatpurity'] is double)
                ? item['karatpurity'] as double
                : double.tryParse(item['karatpurity'].toString()) ?? 0.0;
          } else if (item['karatPurity'] != null) {
            karatpurity = (item['karatPurity'] is double)
                ? item['karatPurity'] as double
                : double.tryParse(item['karatPurity'].toString()) ?? 0.0;
          }

          double productprice = 0.0;
          if (item['productprice'] != null) {
            productprice = (item['productprice'] is double)
                ? item['productprice'] as double
                : double.tryParse(item['productprice'].toString()) ?? 0.0;
          }
          // get image path from item['imagepath'] which is a list of strings
          if (item['imagepath'] != null && item['imagepath'] is List) {
            imagepath = List<String>.from(item['imagepath']);
          } else {
            imagepath = [];
          }

          ProductModel productModel = ProductModel(
            id: id,
            subcatid: 0,
            prodname: prodname,
            prodweight: prodweight,
            prodpurity: 0.0,
            karatpurity: karatpurity,
            stamp: 'stamp',
            wastage: 0.0,
            labourpergm: 0.0,
            margin: 0.0,
            returnpurity: 0.0,
            ishallmark: false,
            ishuid: false,
            huidno: 'huidno',
            owner: 'ramji',
            imagepath: imagepath,
            searchtext: searchtext,
            productprice: productprice,
          );

          log('Parsed ProductModel: ${productModel.prodname}');
          allProductss.add(productModel);
        }

        if (!mounted) return;
        setState(() {
          allproducts = allProductss;
          filteredProducts = List<ProductModel>.from(allProductss);
          _applyProductSearch(_searchController.text);
          // _stockImageUrls
          //   ..clear()
          //   ..addAll(imageMap);
          log('allProductss is ${allproducts.length}');
        });
      } else {
        _showErrorSnackBar(
          'Unable to load categories. Server error (${response.statusCode}).',
        );
      }
    } on TimeoutException {
      _showErrorSnackBar('Server is down or not responding. Please try again.');
    } on SocketException {
      _showErrorSnackBar('Network is down. Please check internet connection.');
    } on http.ClientException {
      _showErrorSnackBar('Cannot connect to server. Please check network.');
    } catch (e) {
      _showErrorSnackBar('Server is down. Please try again later.');
      log('getAllCategories error: $e');
    }
  }

  Future<void> getAllCategory() async {
    final completer = Completer<Object>();
    try {
      List<CategoryModel> allCategories = [];
      String url = AppConfig.GET_CATEGORY;
      log('Fetching categories from URL: $url');
      //final SharedPreferences prefs = await SharedPreferences.getInstance();
      int commodityId = 1; //prefs.getInt('commodityId') ?? 0;
      String body = jsonEncode(commodityId);
      final response = await http
          .post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      )
          .timeout(const Duration(seconds: 15));
      completer.complete(response);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
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
          catname =
              _readString(item, ['catname', 'catName', 'categoryName', 'name']);
          if (item['isactive'] != null) {
            isactive = _readBool(item['isactive']);
          }
          if (item['commodityId'] != null) {
            commodityId = (item['commodityId'] is int)
                ? item['commodityId'] as int
                : int.tryParse(item['commodityId'].toString()) ?? 0;
          }
          if (item['commodityName'] != null) {
            commodityName = item['commodityName'].toString();
          }
          if (item['description'] != null) {
            description = item['description'].toString();
          }

          if (item['catimages'] != null &&
              item['catimages'] is Map<String, dynamic>) {
            catimages = Map<String, String>.from(
                item['catimages'] as Map<String, dynamic>);
          }

          CategoryModel categoryModel = CategoryModel(
            id: id,
            catname: catname,
            isactive: isactive,
            commodityId: commodityId,
            commodityName: commodityName,
            description: description,
            catimages: catimages,
          );
          log('Parsed CategoryModel: ${categoryModel.catimages}');
          allCategories.add(categoryModel);
        }

        if (!mounted) return;
        setState(() {
          allcategories = allCategories;
          // _stockImageUrls
          //   ..clear()
          //   ..addAll(imageMap);
          log('allCategories is ${allCategories.length}');
        });
      } else {
        _showErrorSnackBar(
          'Unable to load categories. Server error (${response.statusCode}).',
        );
      }
    } on TimeoutException catch (e) {
      log(e.message ?? 'TimeoutException occurred');
      _showErrorSnackBar('Server is down or not responding. Please try again.');
    } on SocketException {
      _showErrorSnackBar('Network is down. Please check internet connection.');
    } on http.ClientException {
      _showErrorSnackBar('Cannot connect to server. Please check network.');
    } catch (e) {
      _showErrorSnackBar('Server is down. Please try again later.');
      log('getAllCategories error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
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

  final List<Map<String, String>> products = [
    {
      'name': 'Eternal Glow Ring',
      'price': '₹24,990',
      'image': 'assets/ring1.png',
    },
    {
      'name': 'Luna Pendant',
      'price': '₹18,500',
      'image': 'assets/pendant1.png',
    },
    {
      'name': 'Radiant Drop Earrings',
      'price': '₹16,750',
      'image': 'assets/earrings1.png',
    },
  ];

  final List<String> _bannerImages = const [
    'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1610375461246-83df859d849d?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?auto=format&fit=crop&w=1400&q=80',
  ];

  final List<String> _bannerImagesHeaderText = const [
    'Timeless Beauty',
    'Timeless Beauty1',
    'Timeless Beauty2',
    'Timeless Beauty3',
  ];

  final List<String> _bannerImagesHeading = const [
    'Shine in every moment',
    'Embrace the elegance',
    'Radiate your style',
    'Capture the essence',
  ];

  final List<String> _bannerImagesHeadingBottom = const [
    'exquisite designs crafted to celebrate you.',
    'where elegance meets craftsmanship.',
    'Radiate confidence with every piece.',
    'Celebrate life\'s moments with timeless elegance.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E8),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8EA),
              Color(0xFFF6ECD9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildSearchBar(),
              _buildBanner(),
              KeyedSubtree(
                key: _categorySectionKey,
                child: _buildCategoryChips(),
              ),
              KeyedSubtree(
                key: _productsSectionKey,
                child: _buildTopPicks(),
              ),
              _buildFeaturesSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Bottombar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5C4300),
      foregroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: _openMainMenu,
      ),
      title: Column(
        children: [
          const Text(
            'THE TD',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'JEWELS',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                _shoppingState.favouriteCount > 0
                    ? Icons.favorite
                    : Icons.favorite_outline,
                color: Colors.white,
              ),
              onPressed: _openFavouriteList,
            ),
            if (_shoppingState.favouriteCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_shoppingState.favouriteCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
              onPressed: _openCartList,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _shoppingState.cartCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _applyProductSearch(String query) {
    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      setState(() {
        filteredProducts = List<ProductModel>.from(allproducts);
      });
      return;
    }

    final results = allproducts.where((product) {
      final name = product.prodname.toLowerCase();
      final searchText = product.searchtext.toLowerCase();
      final weight = product.prodweight.toString().toLowerCase();
      return name.contains(keyword) ||
          searchText.contains(keyword) ||
          weight.contains(keyword);
    }).toList(growable: false);

    setState(() {
      filteredProducts = results;
    });
  }

  bool _isFavourite(ProductModel product) {
    return _shoppingState.isFavourite(_productData(product));
  }

  void _toggleFavourite(ProductModel product) {
    _shoppingState.toggleFavourite(_productData(product));
  }

  void _openFavouriteList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = _shoppingState.favourites;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Favourite Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                  child: Text(
                    'No favourites yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
                    : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    final imagePaths = product['imagepath'];
                    final imageUrl =
                    imagePaths is List && imagePaths.isNotEmpty
                        ? imagePaths.first.toString()
                        : '';
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.isEmpty
                            ? const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                              Icons.image_not_supported_outlined),
                        )
                            : Image.network(
                          imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                          const SizedBox(
                            width: 44,
                            height: 44,
                            child:
                            Icon(Icons.broken_image, size: 18),
                          ),
                        ),
                      ),
                      title: Text(
                        product['prodname']?.toString() ?? 'Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${product['prodweight'] ?? '-'} gm',
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            _shoppingState.toggleFavourite(product),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCartList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = _shoppingState.cart;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: items.isEmpty
              ? const Center(child: Text('No products in cart.'))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final price = double.tryParse(
                  item['productprice']?.toString() ?? '') ??
                  0;
              return ListTile(
                title: Text(item['prodname']?.toString() ?? 'Product'),
                subtitle: Text(
                  '₹ ${price.toStringAsFixed(2)}',
                ),
                trailing: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFFD4AF37),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openMainMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Main menu',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final halfHeight = MediaQuery.of(dialogContext).size.height * 0.4;
        final halfwidth = MediaQuery.of(dialogContext).size.width * 0.5;
        return SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: const Color(0xFFD4AF37),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: SizedBox(
                width: halfwidth,
                height: halfHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined),
                        title: const Text('Contact Us'),
                        subtitle: const Text('Get help from our team'),
                        onTap: () {
                          // Navigator.of(dialogContext).pop();
                          // _showContactUsDialog();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ContactUs()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on_outlined),
                        title: const Text('Gold Rate'),
                        subtitle: const Text('Jump to gold rate section'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Commodityrate()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Products'),
                        subtitle: const Text('Jump to products section'),
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _scrollToSection(_productsSectionKey);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  void _scrollToSection(GlobalKey sectionKey) {
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      final sectionContext = sectionKey.currentContext;
      if (sectionContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    });
  }

  void _showContactUsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Us'),
          content: const Text(
            'For product enquiries or order support, please contact our store team.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _applyProductSearch,
              decoration: InputDecoration(
                hintText: 'Search for rings, earrings, pendants...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBanner() {
  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: 280,
  //         child: PageView.builder(
  //           itemCount: _bannerImages.length,
  //           onPageChanged: (index) {
  //             setState(() => _currentBannerIndex = index);
  //           },
  //           itemBuilder: (context, index) {
  //             return Container(
  //               margin: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(16),
  //                 image: DecorationImage(
  //                   image: NetworkImage(_bannerImages[index]),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               child: Stack(
  //                 children: [
  //                   Positioned.fill(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(16),
  //                         gradient: const LinearGradient(
  //                           begin: Alignment.topCenter,
  //                           end: Alignment.bottomCenter,
  //                           colors: [
  //                             Color.fromRGBO(0, 0, 0, 0.28),
  //                             Color.fromRGBO(0, 0, 0, 0.55),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(24),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           _bannerImagesHeaderText[index],
  //                           style: TextStyle(
  //                             color: Color(0xFFD4AF37),
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w600,
  //                             letterSpacing: 2,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         Text(
  //                           _bannerImagesHeading[index],
  //                           style: TextStyle(
  //                             fontSize: 32,
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white,
  //                             height: 1.2,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         Text(
  //                           _bannerImagesHeadingBottom[index],
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.white70,
  //                             height: 1.5,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 24,
  //                             vertical: 12,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: Colors.black87,
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: const Row(
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: [
  //                               Text(
  //                                 'SHOP NOW',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.bold,
  //                                   letterSpacing: 1,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 8),
  //                               Icon(
  //                                 Icons.arrow_forward,
  //                                 color: Colors.white,
  //                                 size: 14,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           for (int i = 0; i < _bannerImages.length; i++)
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 6),
  //               child: Container(
  //                 width: i == _currentBannerIndex ? 20 : 8,
  //                 height: 8,
  //                 decoration: BoxDecoration(
  //                   color: i == _currentBannerIndex
  //                       ? Colors.black87
  //                       : Colors.grey[300],
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //       const SizedBox(height: 24),
  //     ],
  //   );
  // }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(_bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.28),
                              Color.fromRGBO(0, 0, 0, 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _bannerImagesHeaderText[index],
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bannerImagesHeading[index],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bannerImagesHeadingBottom[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'SHOP NOW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _bannerImages.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: i == _currentBannerIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentBannerIndex
                        ? Colors.black87
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryChips() {
    log('allcategories length: ${allcategories.length}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allcategories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = index);
                            final categoryId = allcategories[index].id ?? 0;
                            if (categoryId > 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubCategoryScreen(
                                    categoryId: categoryId,
                                    categoryName:
                                    allcategories[index].catname ?? '',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                              border: _selectedCategory == index
                                  ? Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              )
                                  : null,
                            ),
                            child: ClipOval(
                              child: _buildCategoryChipImage(index),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (allcategories[index].catname?.trim().isNotEmpty ??
                            false)
                            ? allcategories[index].catname!
                            : 'Category ${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedCategory == index
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(int index) {
    // get image from category model if available, else use default icons
    if (index < allcategories.length &&
        allcategories[index].catimages != null) {
      // Here you can implement logic to return an appropriate icon based on the category's image or name.
      // For simplicity, we'll return a default icon for now.
      return Icons.category;
    }

    const icons = [
      Icons.favorite_outline,
      Icons.diamond_outlined,
      Icons.star_outline,
      Icons.watch_outlined,
      Icons.card_giftcard_outlined,
    ];
    return icons[index % icons.length];
  }

  Widget _buildCategoryChipImage(int index) {
    final category = allcategories[index];
    final imageUrl = category.catimages?['url']?.trim() ?? '';

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            _getCategoryIcon(index),
            size: 32,
            color: _selectedCategory == index
                ? const Color(0xFFD4AF37)
                : Colors.grey[600],
          );
        },
      );
    }

    return Icon(
      _getCategoryIcon(index),
      size: 32,
      color: _selectedCategory == index
          ? const Color(0xFFD4AF37)
          : Colors.grey[600],
    );
  }

  Widget _buildTopPicks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOP PICKS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _openAllCategoriesPopup,
                  child: Row(
                    children: [
                      const Text(
                        'VIEW ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.66,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(filteredProducts[index]);
            },
          ),
        ],
      ),
    );
  }

  void _openAllCategoriesPopup() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8EA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'All Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C4300),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: allcategories.isEmpty
                    ? const Center(
                  child: Text(
                    'No categories available.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                  itemCount: allcategories.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final category = allcategories[index];
                    final categoryId = category.id ?? 0;
                    final categoryName =
                    (category.catname?.trim().isNotEmpty ?? false)
                        ? category.catname!
                        : 'Category ${index + 1}';
                    final imageUrl =
                        category.catimages?['url']?.trim() ?? '';

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          if (categoryId > 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SubCategoryScreen(
                                  categoryId: categoryId,
                                  categoryName: categoryName,
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE7D5B2),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stack) {
                                      return Icon(
                                        _getCategoryIcon(index),
                                        size: 34,
                                        color:
                                        const Color(0xFFD4AF37),
                                      );
                                    },
                                  )
                                      : Icon(
                                    _getCategoryIcon(index),
                                    size: 34,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              categoryName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A2B00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openProductImageCarousel(product),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: product.imagepath.isNotEmpty
                          ? Image.network(
                        product.imagepath[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: _buildProductFallbackAvatar(
                              product.prodname,
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: _buildProductFallbackAvatar(
                          product.prodname,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavourite(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavourite(product)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            size: 14,
                            color: _isFavourite(product)
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAEE),
                border: Border(
                  top: BorderSide(color: Color(0xFFE4C26A), width: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top block: name and details (flexible)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRODUCT NAME',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF927328),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.prodname + '  ₹ ${product.productprice.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4D3700),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProductDetail(
                                label: 'PURITY',
                                value: '${product.karatpurity.toStringAsFixed(2)}K',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildProductDetail(
                                label: 'WEIGHT',
                                value: '${product.prodweight.toStringAsFixed(2)} g',
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom block: amount and action (slimmed padding)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C4300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // const Text(
                        //   'AMOUNT',
                        //   style: TextStyle(
                        //     fontSize: 9,
                        //     color: Color(0xFFFFE7A3),
                        //     fontWeight: FontWeight.w700,
                        //     letterSpacing: 0.6,
                        //   ),
                        // ),
                        // const Spacer(),
                        Flexible(
                          child: Text(
                            '₹ ${product.productprice.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            _shoppingState.addToCart(_productData(product));
                            log(
                              'Added product to shopping cart. Total items: ${_shoppingState.cartCount}',
                            );
                          },
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE7D5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF927328),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF4D3700),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductFallbackAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '-',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  void _openProductImageCarousel(ProductModel product) {
    final imageUrls = product.imagepath
        .where((url) => url.trim().isNotEmpty)
        .toList(growable: false);

    if (imageUrls.isEmpty) {
      _showErrorSnackBar('No product images available.');
      return;
    }

    final pageController = PageController(initialPage: 0);
    int currentIndex = 0;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.black87,
              insetPadding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.62,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setModalState(() => currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (index) {
                          return Container(
                            width: currentIndex == index ? 16 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => pageController.dispose());
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem(
            icon: Icons.verified_outlined,
            title: 'CERTIFIED\nDIAMONDS',
          ),
          _buildFeatureItem(
            icon: Icons.schedule_outlined,
            title: '15 DAY\nRETURNS',
          ),
          _buildFeatureItem(
            icon: Icons.card_giftcard_outlined,
            title: 'PREMIUM\nPACKAGING',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: const Color(0xFFD4AF37),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            label: 'COLLECTION',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'SEARCH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'WISHLIST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }
}
