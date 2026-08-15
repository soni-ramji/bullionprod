import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/model/CategoryModel.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/screen/commodityrate.dart';
import 'package:bullionprod/screen/contactus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class home1 extends StatefulWidget {
  const home1({super.key});

  @override
  State<home1> createState() => _home1State();
}


class _home1State extends State<home1> {

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
    // getAllCategory();
    // gerAllProducts();
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
              // onPressed: _openCartList,
              onPressed: ()=>{},
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
                                  builder: (context) => const Commodityrate(

                                  )));
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
  Widget _buildBanner() {
    // Responsive horizontal banner: height and item width adapt to available width
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final bannerHeight = maxWidth * 0.35; // ~35% of available width
        final itemWidth = maxWidth * 0.45; // each card ~45% of available width

        return SizedBox(
          height: bannerHeight.clamp(120.0, 320.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _bannerImages.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: itemWidth.clamp(120.0, 400.0),
                    color: Colors.grey[200],
                    child: Image.network(
                      _bannerImages[index],
                      fit: BoxFit.cover,
                      // show progress indicator while loading
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, error, stack) => Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
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
    return Scaffold(backgroundColor: const Color(0xFFF8F2E8),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildBanner()),
        ],
      )
    );
  }
}
