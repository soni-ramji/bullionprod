
import 'dart:developer';

import 'package:bullionprod/app_shopping_state.dart';
import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/service/BullionUtil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Productwidget extends StatefulWidget {

   Productwidget({super.key, required this.productModel});
   ProductModel productModel;


  @override
  State<Productwidget> createState() => _ProductwidgetState();
}

class _ProductwidgetState extends State<Productwidget> {

  final AppShoppingState _shoppingState = AppShoppingState.instance;
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
    final imageUrls = product.imagepath
        .where((url) => url.trim().isNotEmpty)
        .toList(growable: false);

    if (imageUrls.isEmpty) {
      BullionUtil.showErrorSnackBar('No product images available.');
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
  Widget _buildProductCard(ProductModel product) {
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
                      child: product.imagepath.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: product.imagepath[0],
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
                      )
                      // Image.network(
                      //   product.imagepath[0],
                      //   fit: BoxFit.cover,
                      //   errorBuilder: (context, error, stackTrace) {
                      //     return Container(
                      //       color: Colors.grey[200],
                      //       alignment: Alignment.center,
                      //       child: _buildProductFallbackAvatar(
                      //         product.prodname,
                      //       ),
                      //     );
                      //   },
                      // )
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
                        Text(
                          product.prodname +
                              '  ₹ ${product.productprice.toStringAsFixed(2)}',
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
                                child: Align(
                                  alignment: Alignment.centerRight,
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
}

Widget _buildProductFallbackAvatar(String name) {
  return Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '-',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
  );
}





