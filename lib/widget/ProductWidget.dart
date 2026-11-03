
import 'dart:async';
import 'dart:developer';

import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/screen/ProdDescScreen.dart';
import 'package:bullionprod/service/BullionUtil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Productwidget extends StatefulWidget {

   Productwidget({super.key, required this.productModel});
   ProductModel productModel;


  @override
  State<Productwidget> createState() => _ProductwidgetState();
}

class _ProductwidgetState extends State<Productwidget> {

  final AppShoppingState _shoppingState = AppShoppingState.instance;
  final PageController _imagePageController = PageController();
  Timer? _imageCarouselTimer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _startImageCarousel();
  }

  @override
  void didUpdateWidget(covariant Productwidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productModel != widget.productModel) {
      _currentImageIndex = 0;
      _startImageCarousel();
    }
  }

  @override
  void dispose() {
    _imageCarouselTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductCard(widget.productModel);
  }

  bool _isFavourite(ProductModel product) {
    return _shoppingState.isFavourite(product);
  }



  void _toggleFavourite(ProductModel product) {
    _shoppingState.toggleFavourite(product);
  }

  void _openProductImageCarousel(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Proddescscreen(productModel: product)),
    );

  }

  void _startImageCarousel() {
    _imageCarouselTimer?.cancel();
    final imageUrls = widget.productModel.imagepath
        .where((url) => url.trim().isNotEmpty)
        .toList();
    if (imageUrls.length < 2) return;

    _imageCarouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      final nextIndex = (_currentImageIndex + 1) % imageUrls.length;
      _imagePageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
      setState(() => _currentImageIndex = nextIndex);
    });
  }

  Widget _buildProductCard(ProductModel product) {
    final formattedPrice = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(product.productprice);

    final imageUrls = product.imagepath
        .where((url) => url.trim().isNotEmpty)
        .toList();

    log(product.imagepath[0]);
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
                onTap: () => _openProductImageCarousel(product),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrls.isNotEmpty
                          ? PageView.builder(
                              controller: _imagePageController,
                              itemCount: imageUrls.length,
                              onPageChanged: (index) {
                                if (!mounted) return;
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: imageUrls[index],
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
                      height: 10,
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

                        const SizedBox(height: 1),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                product.prodname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4D3700),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedPrice,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5C4300),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProductDetail(
                                label: 'PURITY',
                                value:
                                '${product.karatpurity.toStringAsFixed(2)}K',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildProductDetail(
                                label: 'WEIGHT',
                                value:
                                '${product.prodweight.toStringAsFixed(2)} g',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                              //   'AMNT',
                              //   style: TextStyle(
                              //     fontSize: 9,
                              //     color: Color(0xFFFFE7A3),
                              //     fontWeight: FontWeight.w700,
                              //     letterSpacing: 0.6,
                              //   ),
                              // ),
                              // const SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    formattedPrice,
                                    maxLines: 1,
                                    //overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    _shoppingState.addToCart(
                                      product,
                                    );
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
                              ),
                            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minHeight: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE7D5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 7.5,
              color: Color(0xFF927328),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF4D3700),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProductFallbackAvatar(String name) {
  return Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '-',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
  );
}





