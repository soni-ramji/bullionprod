import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:bullionprod/main.dart';
import 'package:bullionprod/model/BannerOut.dart';

import 'package:bullionprod/screen/ProductSearchScreen.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:bullionprod/widget/ProductWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  List<Bannerout> allBanners = [];
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
  int _topPicksVisible = 4; // number of top picks to show initially
  final List<GlobalKey> _topPickKeys = []; // keys for each top-pick item to enable scrolling
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  final TextEditingController _searchController = TextEditingController();
  late final Future<void> _homeDataFuture;
  int customerId = -1;
  @override
  void initState() {
    super.initState();
    customerId = prefs.getInt("customerId") ?? -1;
    _shoppingState.addListener(_onShoppingStateChanged);
    _scrollController.addListener(_onScrollToLoadMoreTopPicks);
    _homeDataFuture = _loadHomeData();
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    if (allBanners.length < 2) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;

      final nextIndex = (_currentBannerIndex + 1) % allBanners.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 1800),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentBannerIndex = nextIndex);
    });
  }

  Future<void> _loadHomeData() async {
    await Future.wait<void>([getAllCategory(), gerAllProducts(), getAllBanner()]);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _shoppingState.removeListener(_onShoppingStateChanged);
    _scrollController.removeListener(_onScrollToLoadMoreTopPicks);
    _bannerController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onShoppingStateChanged() {
    if (mounted) setState(() {});
  }

  void _onScrollToLoadMoreTopPicks() {
    if (!mounted || filteredProducts.isEmpty) return;
    if (_topPicksVisible >= filteredProducts.length) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.position.pixels >= maxScroll - 200) {
      setState(() {
        _topPicksVisible = (_topPicksVisible + 4).clamp(0, filteredProducts.length);
      });
    }
  }



  Future<void> gerAllProducts() async {

      if (mounted) setState(() => _isLoadingProducts = true);
      List<ProductModel> allProductss = [];
      String url = AppConfig.GET_PRODUCTS;

      ApiService _apiService = ApiService();
      allProductss =await _apiService.gerAllProducts();



        if (!mounted) return;
        setState(() {
          allproducts = allProductss;
          filteredProducts = allproducts;
          _topPicksVisible = filteredProducts.length > 0 ? 4 : 0;
          _isLoadingProducts = false;

          log('allProductss is ${allproducts.length}');
        });
  }

  Future<void> getAllBanner() async {

    if (mounted) setState(() => _isLoadingProducts = true);
    List<Bannerout> allBannerss = [];
    String url = AppConfig.GET_BANNER_IMAGES;

    ApiService _apiService = ApiService();
    allBannerss =await _apiService.getAllBanners();



    if (!mounted) return;
    setState(() {
      allBanners = allBannerss;
      _isLoadingProducts = false;
      log('allBannerss is ${allBanners.length}');
    });

    if (mounted) {
      _startBannerAutoScroll();
    }
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
          bottomNavigationBar: const Bottombar(selectedIndex: 0),
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

    );
  }



  void _openProductSearchScreen() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProductSearchScreen()),
    );
  }







  Widget _buildSearchBar1() {
    return Container(
      height: 46,

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
          fillColor: Color(0xFFF9F3E8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0), // Adjust the value for more/less roundness
            ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
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
          height: 230,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: allBanners.length,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(allBanners[index].bannerImage ?? ''),
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
                            allBanners[index].bannerHeaderText ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allBanners[index].bannerImageHeading ?? '',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4AF37),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allBanners[index].bannerImageBottom ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // const SizedBox(height: 16),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     for (int i = 0; i < allBanners.length; i++)
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 6),
        //         child: Container(
        //           width: i == _currentBannerIndex ? 20 : 8,
        //           height: 8,
        //           decoration: BoxDecoration(
        //             color: i == _currentBannerIndex
        //                 ? Colors.black87
        //                 : Colors.grey[300],
        //             borderRadius: BorderRadius.circular(4),
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
        // const SizedBox(height: 24),
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
    return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    memCacheWidth: 190,
    placeholder: (context, url) => const Center(
      child: CircularProgressIndicator(
        strokeWidth: 1,
      ),
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
    // return Icon(
    //   _getCategoryIcon(index),
    //   size: 32,
    //   color: _selectedCategory == index
    //       ? const Color(0xFFD4AF37)
    //       : Colors.grey[600],
    // );
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // const Text(
              //   'TOP PICKS',
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w700,
              //     color: Colors.black87,
              //   ),
              // ),
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
              : Column(
                  children: [
                    // ensure there are keys for products
                    () {
                      while (_topPickKeys.length < filteredProducts.length) {
                        _topPickKeys.add(GlobalKey());
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.66,
                        ),
                        // show only a slice of products based on _topPicksVisible
                        itemCount: filteredProducts.length > _topPicksVisible
                            ? _topPicksVisible
                            : filteredProducts.length,
                        itemBuilder: (context, index) {
                          return KeyedSubtree(
                            key: _topPickKeys[index],
                            child: Productwidget(productModel: filteredProducts[index]),
                          );
                        },
                      );
                    }(),

                  ],
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
