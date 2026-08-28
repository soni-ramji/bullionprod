//
//
// import 'package:flutter/material.dart';
//
// class Productwidget extends StatelessWidget {
//    Productwidget({super.key, required this.items});
//    Map<String, dynamic> items = {};
//   final ink = Color(0xFF102D38);
//    final gold = Color(0xFFD39743);
//   late final name = _readString(items, ['prodname', 'name']);
//   late final imageUrl = _readImageUrl(items);
//    late final karatPurity = _readDouble(items, ['karatpurity', 'karatPurity']);
//    late final productWeight = _readDouble(items, [
//     'prodweight',
//     'productweight',
//     'productWeight',
//     'netweight',
//     'netWeight',
//     'grossweight',
//     'grossWeight',
//     'wt',
//   ]);
//   late final productPrice = _readDouble(
//       items, ['productprice', 'productPrice', 'price', 'mrp', 'sellprice']);
//
//   String _readString(Map<String, dynamic> item, List<String> keys) {
//     for (final key in keys) {
//       final value = item[key];
//       if (value != null && value.toString().trim().isNotEmpty) {
//         return value.toString().trim();
//       }
//     }
//     return '-';
//   }
//
//   double _readDouble(Map<String, dynamic> item, List<String> keys) {
//     for (final key in keys) {
//       final value = item[key];
//       if (value == null) continue;
//       if (value is num) return value.toDouble();
//       final parsed = double.tryParse(value.toString());
//       if (parsed != null) return parsed;
//     }
//     return 0;
//   }
//
//   String _readImageUrl(Map<String, dynamic> item) {
//     final imagePathValue = item['imagepath'];
//     if (imagePathValue is List) {
//       for (final raw in imagePathValue) {
//         final candidate = raw?.toString().trim() ?? '';
//         if (candidate.isNotEmpty) {
//           return candidate;
//         }
//       }
//     } else if (imagePathValue is String && imagePathValue.trim().isNotEmpty) {
//       return imagePathValue.trim();
//     }
//
//     final directUrl = _readString(item, [
//       'imageUrl',
//       'imagename',
//       'image',
//       'url',
//     ]);
//     if (directUrl != '-' && directUrl.trim().isNotEmpty) {
//       return directUrl;
//     }
//
//     final imageMap =
//         item['subcatimages'] ?? item['catimages'] ?? item['images'];
//     if (imageMap is Map) {
//       final map = Map<String, dynamic>.from(imageMap);
//
//       final nestedImagePath = map['imagepath'];
//       if (nestedImagePath is List) {
//         for (final raw in nestedImagePath) {
//           final candidate = raw?.toString().trim() ?? '';
//           if (candidate.isNotEmpty) {
//             return candidate;
//           }
//         }
//       } else if (nestedImagePath is String &&
//           nestedImagePath.trim().isNotEmpty) {
//         return nestedImagePath.trim();
//       }
//
//       final mappedUrl = _readString(map, [
//         'url',
//         'imageUrl',
//         'path',
//         'filename',
//       ]);
//       if (mappedUrl != '-' && mappedUrl.trim().isNotEmpty) {
//         return mappedUrl;
//       }
//     }
//
//     return '';
//   }
//
//   List<String> _readImageUrls(Map<String, dynamic> item) {
//     final urls = <String>[];
//
//     final imagePathValue = item['imagepath'];
//     if (imagePathValue is List) {
//       for (final raw in imagePathValue) {
//         final candidate = raw?.toString().trim() ?? '';
//         if (candidate.isNotEmpty) {
//           urls.add(candidate);
//         }
//       }
//     } else if (imagePathValue is String && imagePathValue.trim().isNotEmpty) {
//       urls.add(imagePathValue.trim());
//     }
//
//     final imageMap =
//         item['subcatimages'] ?? item['catimages'] ?? item['images'];
//     if (imageMap is Map) {
//       final map = Map<String, dynamic>.from(imageMap);
//       final nestedImagePath = map['imagepath'];
//
//       if (nestedImagePath is List) {
//         for (final raw in nestedImagePath) {
//           final candidate = raw?.toString().trim() ?? '';
//           if (candidate.isNotEmpty) {
//             urls.add(candidate);
//           }
//         }
//       } else if (nestedImagePath is String &&
//           nestedImagePath.trim().isNotEmpty) {
//         urls.add(nestedImagePath.trim());
//       }
//
//       for (final key in ['url', 'imageUrl', 'path', 'filename']) {
//         final value = map[key]?.toString().trim() ?? '';
//         if (value.isNotEmpty) {
//           urls.add(value);
//         }
//       }
//     }
//
//     // Keep order while removing duplicates/empty values.
//     final seen = <String>{};
//     final unique = <String>[];
//     for (final url in urls) {
//       if (url.isEmpty || seen.contains(url)) continue;
//       seen.add(url);
//       unique.add(url);
//     }
//
//     return unique;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//
//           Expanded(
//             flex: 4,
//             child: MouseRegion(
//               cursor: SystemMouseCursors.click,
//               child: GestureDetector(
//                 onTap: () => _openProductImageCarousel(item),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: imageUrl.isNotEmpty
//                           ? Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             color: Colors.grey[200],
//                             alignment: Alignment.center,
//                             child: _buildFallbackAvatar(name),
//                           );
//                         },
//                       )
//                           : Container(
//                         color: Colors.grey[200],
//                         alignment: Alignment.center,
//                         child: _buildFallbackAvatar(name),
//                       ),
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: GestureDetector(
//                         onTap: () => _toggleFavourite(item),
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.12),
//                                 blurRadius: 4,
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             _isFavourite(item)
//                                 ? Icons.favorite
//                                 : Icons.favorite_outline,
//                             size: 14,
//                             color:
//                             _isFavourite(item) ? Colors.red : Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFFAEE),
//                 border: Border(
//                   top: BorderSide(color: const Color(0xFFE4C26A), width: 0.8),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top block: allow to take only needed space
//                   Flexible(
//                     fit: FlexFit.loose,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           'PRODUCT NAME',
//                           style: TextStyle(
//                             fontSize: 8,
//                             color: Color(0xFF927328),
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 0.8,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           '$name - ₹ ${productPrice.toStringAsFixed(2)}',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF4D3700),
//                             height: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildProductDetail(
//                                 label: 'PURITY',
//                                 value: '${karatPurity.toStringAsFixed(2)}K',
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Expanded(
//                               child: _buildProductDetail(
//                                 label: 'WEIGHT',
//                                 value: productWeight > 0
//                                     ? '${productWeight.toStringAsFixed(2)} g'
//                                     : '-',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   //Bottom block: fixed height to prevent overflow
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF5C4300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const Text(
//                           'AMOUNT',
//                           style: TextStyle(
//                             fontSize: 9,
//                             color: Color(0xFFFFE7A3),
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 0.6,
//                           ),
//                         ),
//                         const Spacer(),
//                         Flexible(
//                           child: Text(
//                             '₹ ${productPrice.toStringAsFixed(2)}',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         GestureDetector(
//                           onTap: () => _addToCart(item),
//                           child: const Icon(
//                             Icons.shopping_bag_outlined,
//                             size: 18,
//                             color: Color(0xFFD4AF37),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//    Widget _buildFallbackAvatar(String name) {
//      return Center(
//        child: Text(
//          name.isNotEmpty ? name[0].toUpperCase() : '-',
//          style: const TextStyle(
//            fontWeight: FontWeight.bold,
//            fontSize: 18,
//          ),
//        ),
//      );
//    }
//
//    void _toggleFavourite(Map<String, dynamic> item) {
//      _shoppingState.toggleFavourite(item);
//    }
// }
