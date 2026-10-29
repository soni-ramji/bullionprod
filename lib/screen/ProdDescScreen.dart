import 'package:bullionprod/model/ProductModel.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Proddescscreen extends StatefulWidget {
  const Proddescscreen({super.key, required this.productModel});

  final ProductModel? productModel;

  @override
  State<Proddescscreen> createState() => _ProddescscreenState();
}

class _ProddescscreenState extends State<Proddescscreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  ProductModel? get _product => widget.productModel;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _imageUrls() {
    final product = _product;
    if (product == null || product.imagepath.isEmpty) {
      return const [];
    }
    return product.imagepath.where((url) => url.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final imageUrls = _imageUrls();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A260D),
        foregroundColor: Colors.white,
        title: const Text('Product Details'),
        centerTitle: true,
      ),
      body: product == null
          ? const Center(
              child: Text('No product selected'),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 320,
                              child: imageUrls.isEmpty
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE9D7A8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_rounded,
                                          color: Color(0xFF5C4300),
                                          size: 48,
                                        ),
                                      ),
                                    )
                                  : PageView.builder(
                                      controller: _pageController,
                                      itemCount: imageUrls.length,
                                      onPageChanged: (index) {
                                        setState(() => _currentImageIndex = index);
                                      },
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(22),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrls[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (context, url) => Container(
                                              color: const Color(0xFFF5E7B3),
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF5C4300),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: const Color(0xFFE9D7A8),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Color(0xFF5C4300),
                                                  size: 42,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (imageUrls.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(imageUrls.length, (index) {
                                    final isActive = index == _currentImageIndex;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: isActive ? 22 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFFD4AF37)
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.prodname,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E1C0E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Premium handcrafted gold jewellery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F1F0A), Color(0xFF5C4300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            title: 'Purity',
                            value: '${product.karatpurity.toStringAsFixed(0)}K',
                            icon: Icons.auto_fix_high_rounded,
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          _infoRow(
                            title: 'Weight',
                            value: '${product.prodweight.toStringAsFixed(2)} g',
                            icon: Icons.scale_rounded,
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          _infoRow(
                            title: 'Amount',
                            value: '₹ ${product.productprice.toStringAsFixed(2)}',
                            icon: Icons.currency_rupee_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5D7B1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E1C0E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _detailText('Purity: ${product.karatpurity.toStringAsFixed(2)} K'),
                         // _detailText('Stamp: ${product.stamp.isEmpty ? 'N/A' : product.stamp}'),
                          _detailText('Hallmark: ${product.ishallmark ? 'Yes' : 'No'}'),
                          _detailText('Weight: ${product.prodweight.toStringAsFixed(2)} grams'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const Bottombar(selectedIndex: 0),
    );
  }

  Widget _infoRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.8,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
