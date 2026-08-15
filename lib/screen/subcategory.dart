import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../environment.dart';
import 'productscreen.dart';
import 'home.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen(
      {super.key, required this.categoryId, required this.categoryName});

  final int categoryId;
  final String categoryName;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _subcategories = <Map<String, dynamic>>[];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSubcategories {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _subcategories;

    return _subcategories.where((item) {
      final name = _readString(item, [
        'subcatname',
        'subcategoryname',
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
    final directUrl = _readString(item, [
      'imageurl',
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
      final mappedUrl = _readString(map, [
        'url',
        'imageurl',
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

  Future<void> _loadSubCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.GET_SUBCATEGORY),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(widget.categoryId),
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

      if (!mounted) return;
      setState(() {
        _subcategories = loadedSubcategories;
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
                //_buildHeaderCard(),
                _buildSearchBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.category_outlined, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                  Text(' ${widget.categoryName}'),
                ],
              ),
            ),
            IconButton(
              onPressed: _isLoading ? null : _loadSubCategories,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search ${widget.categoryName} types',
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
              onPressed: _loadSubCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_subcategories.isEmpty) {
      return const Center(
        child: Text(
          'No subcategories found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final subcategories = _filteredSubcategories;
    if (subcategories.isEmpty) {
      return Center(
        child: Text(
          'No subcategories match "${_searchQuery.trim()}".',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      itemCount: subcategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = subcategories[index];
        final name = _readString(item, [
          'subcatname',
          'subcategoryname',
          'subcatName',
          'name',
        ]);
        final subcatId = int.tryParse(
              _readString(item, ['id', 'subcatid', 'subcategoryid']),
            ) ??
            0;
        final imageUrl = _readImageUrl(item);

        return InkWell(
          onTap: () {
            if (subcatId <= 0) {
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductScreen(
                  subcategoryId: subcatId,
                  subcategoryName: name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackAvatar(name);
                            },
                          )
                        : _buildFallbackAvatar(name),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Text(
                    name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
