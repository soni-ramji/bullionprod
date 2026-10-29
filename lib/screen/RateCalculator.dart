import 'package:bullionprod/environment.dart';
import 'package:bullionprod/model/CommodityRateModel.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
late SharedPreferences prefs;
class Ratecalculator extends StatefulWidget {
  const Ratecalculator({super.key});

  @override
  State<Ratecalculator> createState() => _RatecalculatorState();
}

class _RatecalculatorState extends State<Ratecalculator> {
  final TextEditingController _karatController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double goldRate = 0.0;
  double _estimatedAmount = 0.0;
  bool _hasEstimate = false;
  int _selectedKarat = 22;

  final List<int> _karatOptions = [18, 22, 24];

  @override
  void dispose() {
    _karatController.dispose();
    _weightController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _karatController.text = _selectedKarat.toString();
    _weightController.text = '';
    _amountController.text = '';
    //goldRate = 6500.0;
    getCommodityRate();
  }

  Future<void> getCommodityRate() async {
    try {
      ApiService apiService = ApiService();
      CommodityRateModel? commodityRateModel = await apiService.getCommodityRate();
      if (!mounted) return;
      setState(() {
        goldRate = commodityRateModel?.goldsell ?? 0.0;
      });
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  void _calculateAmount() {
    final karat = int.tryParse(_karatController.text) ?? _selectedKarat;
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    if (weight <= 0 || goldRate <= 0) {
      setState(() {
        _estimatedAmount = 0.0;
        _hasEstimate = false;
        _amountController.text = '';
      });
      return;
    }

    final purityRate = goldRate * karat / 24;
    final amount = weight * purityRate/10 + (weight * purityRate/10 * 0.08);

    setState(() {
      _estimatedAmount = amount;
      _hasEstimate = true;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF5C4300);
    const warmBackground = Color(0xFFF8F3E9);
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        title: const Text('Rate Calculator'),
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: const Bottombar(selectedIndex: 6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cardColor, Color(0xFFFDF7EE)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E7B3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gold Rate',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            goldRate > 0 ? '₹ ${goldRate.toStringAsFixed(2)}/g' : 'Loading...',
                            style: const TextStyle(
                              color: darkBrown,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Gold Jewellery Calculator',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkBrown,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quick estimate for your jewellery purchase',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5B3A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Purity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C4300),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _karatOptions.map((karat) {
                        final selected = _selectedKarat == karat;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('${karat}K'),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedKarat = karat;
                                  _karatController.text = karat.toString();
                                });
                              },
                              selectedColor: const Color(0xFF5C4300),
                              backgroundColor: const Color(0xFFF5E7B3),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : const Color(0xFF5C4300),
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide.none,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _karatController,
                      label: 'Karat',
                      icon: Icons.stars_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _weightController,
                      label: 'Weight (in grams)',
                      icon: Icons.scale_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _amountController,
                      label: 'Amount',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton(
                      onPressed: _calculateAmount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Calculate Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_hasEstimate)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F3A2B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Amount',
                              style: TextStyle(
                                color: Color(0xFFE4D5A7),
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${_estimatedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE6D9B5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Note: Amount is estimated using current gold rate and includes making charges.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B6A48),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Color(0xFF2D2418)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFAF7F1),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7A6A4D)),
        prefixIcon: Icon(icon, color: const Color(0xFF5C4300)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4D5A7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4D5A7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5C4300), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}
