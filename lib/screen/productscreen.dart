import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/screen/subcategory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_shopping_state.dart';
import '../environment.dart';
import 'home.dart';
import '../widget/breadcrumb.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(
      {super.key, required this.subcategoryId, required this.subcategoryName, required this.categoryId, required this.categoryName});

  final int subcategoryId;
  final String subcategoryName;
  final int categoryId;
  final String categoryName;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _products = <Map<String, dynamic>>[];
  final AppShoppingState _shoppingState = AppShoppingState.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _shoppingState.addListener(_onShoppingStateChanged);
    _loadProducts();
  }

  void _onShoppingStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _shoppingState.removeListener(_onShoppingStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _products;

    return _products.where((item) {
      final name = _readString(item, [
        'prodname',
        'productname',
        'subcatName',
        'name',
      ]);
      return name.toLowerCase().contains(query);
    }).toList();
  }

  String _readString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '-';
  }

  String _readImageUrl(Map<String, dynamic> item) {
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

    final directUrl = _readString(item, [
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

      final mappedUrl = _readString(map, [
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

  double _readDouble(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
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

  bool _isFavourite(Map<String, dynamic> item) {
    return _shoppingState.isFavourite(item);
  }

  void _toggleFavourite(Map<String, dynamic> item) {
    _shoppingState.toggleFavourite(item);
  }

  void _addToCart(Map<String, dynamic> item) {
    _shoppingState.addToCart(item);
  }

  void _openFavouriteList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final favouriteItems = _shoppingState.favourites;

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
                child: favouriteItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No favourites yet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: favouriteItems.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = favouriteItems[index];
                          final imageUrl = _readImageUrl(item);
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 44,
                                        height: 44,
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 44,
                                      height: 44,
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            title: Text(
                              _readString(item, ['prodname', 'name']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '₹ ${_readDouble(item, [
                                    'productprice',
                                    'productPrice',
                                    'price',
                                    'mrp',
                                    'sellprice'
                                  ]).toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _toggleFavourite(item);
                              },
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
                'Cart Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _shoppingState.cart.isEmpty
                    ? const Center(
                        child: Text(
                          'No products in cart.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _shoppingState.cart.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _shoppingState.cart[index];
                          final imageUrl = _readImageUrl(item);
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 44,
                                        height: 44,
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 44,
                                      height: 44,
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            title: Text(
                              _readString(item, ['prodname', 'name']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '₹ ${_readDouble(item, [
                                    'productprice',
                                    'productPrice',
                                    'price',
                                    'mrp',
                                    'sellprice'
                                  ]).toStringAsFixed(2)}',
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.GET_PRODUCT),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(widget.subcategoryId),
          )
          .timeout(const Duration(seconds: 15));

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

      final loadedSubcategories = <Map<String, dynamic>>[];
      for (final rawItem in listItem) {
        if (rawItem == null || rawItem is! Map) continue;
        loadedSubcategories.add(Map<String, dynamic>.from(rawItem));
      }

      _debugProductPriceFields(loadedSubcategories);

      if (!mounted) return;
      setState(() {
        _products = loadedSubcategories;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4300),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'THE TD',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
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
                tooltip: 'Favourites',
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
                  child: _buildAppBarBadge(
                    _shoppingState.favouriteCount,
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Shopping cart',
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: _openCartList,
              ),
              if (_shoppingState.cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: _buildAppBarBadge(
                    _shoppingState.cartCount,
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Breadcrumb(
                  items: [
                    BreadcrumbItem('Home', onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    }),
                    BreadcrumbItem(widget.categoryName, onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) =>  SubCategoryScreen(categoryId: widget.categoryId, categoryName: widget.categoryName)),
                            (route) => false,
                      );
                    }),
                    BreadcrumbItem(widget.subcategoryName),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Bottombar(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search ${widget.subcategoryName} types',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4D4B6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAppBarBadge(int count, {required Color backgroundColor}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedNavIndex = index);

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            const Icon(Icons.category_outlined, size: 30),
            const SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Loaded from DB',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(' ${widget.subcategoryName}'),
                ],
              ),

            IconButton(
              onPressed: _isLoading ? null : _loadProducts,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
            ),
          ],
        ),
      ),
    );
  }

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
             onPressed: _loadProducts,
             icon: const Icon(Icons.refresh),
             label: const Text('Try Again'),
           ),
         ],
       ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text(
          'No products found.',
          style: TextStyle(fontSize: 16),
        ),
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
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(product[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    const ink = Color(0xFF102D38);
    const gold = Color(0xFFD39743);
    final name = _readString(item, ['prodname', 'name']);
    final imageUrl = _readImageUrl(item);
    final karatPurity = _readDouble(item, ['karatpurity', 'karatPurity']);
    final productWeight = _readDouble(item, [
      'prodweight',
      'productweight',
      'productWeight',
      'netweight',
      'netWeight',
      'grossweight',
      'grossWeight',
      'wt',
    ]);
    final productPrice = _readDouble(
        item, ['productprice', 'productPrice', 'price', 'mrp', 'sellprice']);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [

          Expanded(
            flex: 4,
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
                        onTap: () => _toggleFavourite(item),
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
                            color:
                                _isFavourite(item) ? Colors.red : Colors.grey,
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
                      ],
                    ),
                  ),

                  //Bottom block: fixed height to prevent overflow
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C4300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'AMOUNT',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFFFE7A3),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
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
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _addToCart(item),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
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

  Widget _buildFallbackAvatar(String name) {
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
        onTap: _onBottomNavTap,
        items: const [
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
