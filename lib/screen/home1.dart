import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bullionprod/main.dart';

import 'package:bullionprod/screen/ProductSearchScreen.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:bullionprod/widget/ProductWidget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullionprod/widget/circular_network_image.dart';
import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/app_scaffold_messenger.dart';
import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CategoryModel.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:bullionprod/screen/login_screen.dart';
import 'package:bullionprod/screen/subcategory.dart';
import 'package:http/http.dart' as http;

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  List<ProductModel> allproducts = [];
  List<ProductModel> filteredProducts = [];
  final AppShoppingState _shoppingState = AppShoppingState.instance;
  List<CategoryModel> allcategories = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categorySectionKey = GlobalKey();
  final GlobalKey _productsSectionKey = GlobalKey();
  int _currentBannerIndex = 0;
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late final Future<void> _homeDataFuture;
  int customerId = -1;
  @override
  void initState() {
    super.initState();
    customerId = prefs.getInt("customerId") ?? -1;
    _shoppingState.addListener(_onShoppingStateChanged);
    _homeDataFuture = _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    await Future.wait<void>([getAllCategory(), gerAllProducts()]);
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



  Future<void> gerAllProducts() async {

      if (mounted) setState(() => _isLoadingProducts = true);
      List<ProductModel> allProductss = [];
      String url = AppConfig.GET_PRODUCTS;

      ApiService _apiService = ApiService();
      allProductss =await _apiService.getAllProductCached();



        if (!mounted) return;
        setState(() {
          allproducts = allProductss;
          filteredProducts = allproducts;
          _isLoadingProducts = false;

          log('allProductss is ${allproducts.length}');
        });
  }


  Future<void> getAllCategory() async {
    // try {
      if (mounted) setState(() => _isLoadingCategories = true);
      int? commodityId = 1;
      ApiService _apiServices = ApiService();
      List<CategoryModel> allCategories =await _apiServices.getAllCategoryCached(commodityId: commodityId);


        if (!mounted) return;
        setState(() {
          allcategories = allCategories;
          _isLoadingCategories = false;
          log('allCategories is ${allCategories.length}');
        });

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
    final content = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8EA), Color(0xFFF6ECD9)],
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // _buildSearchBar(),
            _buildBanner(),
            KeyedSubtree(
              key: _categorySectionKey,
              child: _buildCategoryChips(),
            ),
            KeyedSubtree(key: _productsSectionKey, child: _buildTopPicks()),
            _buildFeaturesSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );

    return FutureBuilder<void>(
      future: _homeDataFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F2E8),
          appBar: _buildAppBar(),
          //appBar: AppBarStless(title: 'THE TD JEWELS'),
          body: RefreshIndicator(
            onRefresh: () async {},
            notificationPredicate: (_) => false,
            child: Stack(
              children: [
                content,
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.12),
                      child: const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF5C4300),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Bottombar(),
        );
      },
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
      // actions: [
      //   Stack(
      //     children: [
      //       IconButton(
      //         icon: Icon(
      //           _shoppingState.favouriteCount > 0
      //               ? Icons.favorite
      //               : Icons.favorite_outline,
      //           color: Colors.white,
      //         ),
      //         onPressed: _openFavouriteList,
      //       ),
      //       if (_shoppingState.favouriteCount > 0)
      //         Positioned(
      //           right: 6,
      //           top: 6,
      //           child: Container(
      //             padding: const EdgeInsets.symmetric(
      //               horizontal: 5,
      //               vertical: 2,
      //             ),
      //             decoration: const BoxDecoration(
      //               color: Colors.red,
      //               shape: BoxShape.circle,
      //             ),
      //             child: Text(
      //               '${_shoppingState.favouriteCount}',
      //               style: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 9,
      //                 fontWeight: FontWeight.w700,
      //               ),
      //             ),
      //           ),
      //         ),
      //     ],
      //   ),
      //   Stack(
      //     children: [
      //       IconButton(
      //         icon: const Icon(
      //           Icons.shopping_bag_outlined,
      //           color: Colors.white,
      //         ),
      //         onPressed: _openCartList,
      //       ),
      //       Positioned(
      //         right: 8,
      //         top: 8,
      //         child: Container(
      //           padding: const EdgeInsets.all(4),
      //           decoration: const BoxDecoration(
      //             color: Color(0xFFD4AF37),
      //             shape: BoxShape.circle,
      //           ),
      //           child: Text(
      //             _shoppingState.cartCount.toString(),
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 10,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      //   if (customerId != -1)
      //     IconButton(
      //       icon: const Icon(Icons.logout, color: Colors.white),
      //       onPressed: _logout,
      //       tooltip: 'Logout',
      //     ),
      // ],
    );
  }



  void _openProductSearchScreen() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProductSearchScreen()),
    );
  }


  bool _isFavourite(ProductModel product) {
    return _shoppingState.isFavourite(product);
  }

  void _toggleFavourite(ProductModel product) {
    _shoppingState.toggleFavourite(product);
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
        onTap: _openProductSearchScreen,
        // onChanged: _applyProductSearch,
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

    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (allcategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No categories available.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

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
        allcategories[index].imagepath != null) {
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
    final imageUrl = category.imagepath?.trim() ?? '';

    if (imageUrl.isNotEmpty) {
      // ensure absolute URL
      final finalUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${AppConfig.baseUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
      return CircularNetworkImage(url: finalUrl, size: 80);
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
    if (_isLoadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

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
          filteredProducts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No products available.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                )
              : GridView.builder(
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
                    return Productwidget(productModel: filteredProducts[index] );
                    //return _buildProductCard(filteredProducts[index]);
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
                child: _isLoadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : allcategories.isEmpty
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
                          final imageUrl = category.imagepath?.trim() ?? '';

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
                                                        color: const Color(
                                                          0xFFD4AF37,
                                                        ),
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

  Widget _buildFeatureItem({required IconData icon, required String title}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFFD4AF37)),
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


}
