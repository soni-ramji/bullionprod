import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bullionprod/model/SubCategoryModel.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/screen/home1.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:bullionprod/widget/breadcrumb.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../environment.dart';
import 'productscreen.dart';
import 'home.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({super.key, required this.categoryId, required this.categoryName});

  final int categoryId;
  final String categoryName;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<SubCategoryModel> _subcategories = [];
  List<SubCategoryModel> _filteredSubcategories = [];

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

  Future<void> _loadSubCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ApiService _apiService = ApiService();
      _subcategories = await _apiService.loadSubCategories(widget.categoryId);
      if (!mounted) return;
      setState(() {
        _filteredSubcategories = _subcategories;
        _isLoading = false;
      });
    }  catch (e, stackTrace) {
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
            colors: [Color(0xFFFFF8EA), Color(0xFFF6ECD9)],
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
                    BreadcrumbItem(
                      'Home',
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen1()),
                          (route) => false,
                        );
                      },
                    ),
                    BreadcrumbItem(widget.categoryName),
                  ],
                ),
                _buildSearchBar(),
                const SizedBox(height: 12),
                Expanded(child: _buildBody()),
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
        MaterialPageRoute(builder: (_) => const HomeScreen1()),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

  void searchItem(String searchText) {
    if (_filteredSubcategories.isNotEmpty) {
      //_filteredSubcategories  = _subcategories.where((subcat))
      setState(() {
        _filteredSubcategories = _subcategories.where((subcat) {
          return subcat.subcatname.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        _filteredSubcategories = _subcategories;
      });
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      // onChanged: (value) => setState(() => _searchQuery = value),
      onChanged: (value) => searchItem(value),
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
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
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
      return const Center(child: Text('No subcategories found.', style: TextStyle(fontSize: 16)));
    }

    //final subcategories = _filteredSubcategories;
    if (_filteredSubcategories.isEmpty) {
      return Center(
        child: Text(
          'No subcategories match "${_searchQuery.trim()}".',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      itemCount: _filteredSubcategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {


        return InkWell(
          onTap: () {
            if (_filteredSubcategories[index].id <= 0) {
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductScreen(
                  subcategoryId: _filteredSubcategories[index].id,
                  subcategoryName: _filteredSubcategories[index].subcatname,
                  categoryId: widget.categoryId,
                  categoryName: widget.categoryName,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: _filteredSubcategories[index].subcatimages.isNotEmpty
                        ? Image.network(
                            _filteredSubcategories[index].subcatimages[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackAvatar(_filteredSubcategories[index].subcatname);
                            },
                          )
                        : _buildFallbackAvatar(_filteredSubcategories[index].subcatname),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Text(
                    _filteredSubcategories[index].subcatname,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Bottombar();
  }
}
