import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/model/ProductSearchCriteria.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/service/BullionUtil.dart';
import 'package:bullionprod/widget/breadcrumb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  // final int subcategoryId;
  // final String subcategoryName;
  // final int categoryId;
  // final String categoryName;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductModel> allproducts = []; // Initialize with your product list
  // List<ProductModel> filteredProducts = [];
  List<Map<String, dynamic>> _products = <Map<String, dynamic>>[];
  final AppShoppingState _shoppingState = AppShoppingState.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedNavIndex = 1;

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loadAllProducts,
              // onPressed: () => {},
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No products found.', style: TextStyle(fontSize: 16)),
      );
    }

    final product = _filteredProducts;
    if (product.isEmpty) {
      return Center(
        child: Text(
          'No products match "${_searchQuery.trim()}".',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      itemCount: product.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(product[index]);
      },
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    // final query = _searchQuery.trim().toLowerCase();
    // if (query.isEmpty) return _products;
    //
    // return _products.where((item) {
    //   final name = BullionUtil.readString(item, [
    //     'prodname',
    //     'productname',
    //     'subcatName',
    //     'name',
    //   ]);
    //   return name.toLowerCase().contains(query);
    // }).toList();
    return _products.toList();
  }

  void loadAllProducts() {
    if (_searchController.text.isNotEmpty) {
      _loadProducts();
    } else {
      allproducts = [];
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    Productsearchcriteria productsearchcriteria = new Productsearchcriteria(
      commodityid: 1,
      searchtext: _searchController.text,
    );

    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.SEARCH_PRODUCT),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(productsearchcriteria.toJson()),
          );
          //.timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw HttpException('Server returned ${response.statusCode}');
      }

      final decoded = json.decode(response.body);
      List<dynamic> listItem = <dynamic>[];

      if (decoded is List) {
        listItem = decoded;
      } else if (decoded is Map) {
        if (decoded['data'] is List) {
          listItem = decoded['data'];
        } else if (decoded['items'] is List) {
          listItem = decoded['items'];
        } else if (decoded['result'] is List) {
          listItem = decoded['result'];
        } else if (decoded['list'] is List) {
          listItem = decoded['list'];
        } else {
          listItem = decoded.values.toList();
        }
      }

      final loadedProducts = <Map<String, dynamic>>[];
      for (final rawItem in listItem) {
        if (rawItem == null || rawItem is! Map) continue;
        loadedProducts.add(Map<String, dynamic>.from(rawItem));
      }

      //_debugProductPriceFields(loadedProducts);

      if (!mounted) return;
      setState(() {
        _products = loadedProducts;
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Server is taking too long to respond.';
        _isLoading = false;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      log('Failed to load subcategories', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load subcategories.';
        _isLoading = false;
      });
    }
  }

  bool _isFavourite(Map<String, dynamic> item) {
    return _shoppingState.isFavourite(item);
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    const ink = Color(0xFF102D38);
    const gold = Color(0xFFD39743);
    final name = BullionUtil.readString(item, ['prodname', 'name']);
    final imageUrl = BullionUtil.readImageUrl(item);
    final karatPurity = BullionUtil.readDouble(item, [
      'karatpurity',
      'karatPurity',
    ]);
    final productWeight = BullionUtil.readDouble(item, [
      'prodweight',
      'productweight',
      'productWeight',
      'netweight',
      'netWeight',
      'grossweight',
      'grossWeight',
      'wt',
    ]);
    final productPrice = BullionUtil.readDouble(item, [
      'productprice',
      'productPrice',
      'price',
      'mrp',
      'sellprice',
    ]);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openProductImageCarousel(item),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: _buildFallbackAvatar(name),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: _buildFallbackAvatar(name),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        //onTap: () => _toggleFavourite(item),
                        onTap: () => {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavourite(item)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            size: 14,
                            color: _isFavourite(item)
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
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEE),
                border: Border(
                  top: BorderSide(color: const Color(0xFFE4C26A), width: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top block: allow to take only needed space
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // const Text(
                        //   'PRODUCT NAME',
                        //   style: TextStyle(
                        //     fontSize: 8,
                        //     color: Color(0xFF927328),
                        //     fontWeight: FontWeight.w700,
                        //     letterSpacing: 0.8,
                        //   ),
                        // ),
                        const SizedBox(height: 2),
                        Text(
                          '$name - ₹ ${productPrice.toStringAsFixed(2)}',
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
                                value: '${karatPurity.toStringAsFixed(2)}K',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildProductDetail(
                                label: 'WEIGHT',
                                value: productWeight > 0
                                    ? '${productWeight.toStringAsFixed(2)} g'
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C4300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'AMNT',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFFFE7A3),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '₹ ${productPrice.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => _addToCart(item),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Bottom block: fixed height to prevent overflow
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF5C4300),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       const Text(
                  //         'AMOUNT',
                  //         style: TextStyle(
                  //           fontSize: 9,
                  //           color: Color(0xFFFFE7A3),
                  //           fontWeight: FontWeight.w700,
                  //           letterSpacing: 0.6,
                  //         ),
                  //       ),
                  //       const Spacer(),
                  //       Flexible(
                  //         child: Text(
                  //           '₹ ${productPrice.toStringAsFixed(2)}',
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: const TextStyle(
                  //             fontSize: 12,
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.w800,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 6),
                  //       GestureDetector(
                  //         onTap: () => _addToCart(item),
                  //         child: const Icon(
                  //           Icons.shopping_bag_outlined,
                  //           size: 18,
                  //           color: Color(0xFFD4AF37),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _readImageUrls(Map<String, dynamic> item) {
    final urls = <String>[];

    final imagePathValue = item['imagepath'];
    if (imagePathValue is List) {
      for (final raw in imagePathValue) {
        final candidate = raw?.toString().trim() ?? '';
        if (candidate.isNotEmpty) {
          urls.add(candidate);
        }
      }
    } else if (imagePathValue is String && imagePathValue.trim().isNotEmpty) {
      urls.add(imagePathValue.trim());
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
            urls.add(candidate);
          }
        }
      } else if (nestedImagePath is String &&
          nestedImagePath.trim().isNotEmpty) {
        urls.add(nestedImagePath.trim());
      }

      for (final key in ['url', 'imageUrl', 'path', 'filename']) {
        final value = map[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          urls.add(value);
        }
      }
    }

    // Keep order while removing duplicates/empty values.
    final seen = <String>{};
    final unique = <String>[];
    for (final url in urls) {
      if (url.isEmpty || seen.contains(url)) continue;
      seen.add(url);
      unique.add(url);
    }

    return unique;
  }

  void _openProductImageCarousel(Map<String, dynamic> item) {
    final imageUrls = _readImageUrls(item);

    if (imageUrls.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No product images available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
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

  Widget _buildFallbackAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '-',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5C4300),
      foregroundColor: Colors.white,
      elevation: 0.5,
      toolbarHeight: 72,
      titleSpacing: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.menu, color: Colors.white),
      //   onPressed: _openMainMenu,
      // ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _buildSearchBar1(),
      ),
      centerTitle: true,
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    _shoppingState.addToCart(item);
  }

  Widget _buildSearchBar1() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F3E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        onSubmitted: (value) {
          _searchController.text = value;
          _searchQuery = value;
          loadAllProducts();
        },
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 13, color: Color(0xFF2E2A28)),
        decoration: InputDecoration(
          hintText: 'Search for rings, earrings, pendants...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12.5),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF5C4300),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  void _debugProductPriceFields(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      log('Product response is empty.');
      return;
    }

    final sampleCount = products.length < 5 ? products.length : 5;
    for (var i = 0; i < sampleCount; i++) {
      final item = products[i];
      log(
        'Product[$i] id=${item['id']} name=${item['prodname'] ?? item['name']} '
        'productprice=${item['productprice']} productPrice=${item['productPrice']} '
        'price=${item['price']} mrp=${item['mrp']} sellprice=${item['sellprice']}',
      );
    }
  }

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
            colors: [Color(0xFFFFF8EA), Color(0xFFF6ECD9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 2),


                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Bottombar(),
    );
  }

  // void _applyProductSearch(String query) {
  //   final keyword = query.trim().toLowerCase();
  //
  //   if (keyword.isEmpty) {
  //     setState(() {
  //       filteredProducts = List<ProductModel>.from(allproducts);
  //     });
  //     return;
  //   }
  //
  //   final results = allproducts
  //       .where((product) {
  //         final name = product.prodname.toLowerCase();
  //         final searchText = product.searchtext.toLowerCase();
  //         final weight = product.prodweight.toString().toLowerCase();
  //         return name.contains(keyword) ||
  //             searchText.contains(keyword) ||
  //             weight.contains(keyword);
  //       })
  //       .toList(growable: false);
  //
  //   setState(() {
  //     filteredProducts = results;
  //   });
  // }
}
