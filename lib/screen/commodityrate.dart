import 'dart:convert';

import 'package:bullionprod/environment.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Commodityrate extends StatefulWidget {

  const Commodityrate({super.key});


  @override
  State<Commodityrate> createState() => _CommodityrateState();
}

class _CommodityrateState extends State<Commodityrate> {
  double gold24k = 0;
  double gold22k = 0;
  double gold18k = 0;
  double silverrate = 0;
  @override
  void initState() {
    super.initState();
       getCommodityRate();
  }

  Future<void> getCommodityRate() async {
    String url = AppConfig.GET_COMMODITY_RATE;
    try {


      final response = await http
          .get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },

      )
          .timeout(const Duration(seconds: 15));
      // completer.complete(response);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);


      setState(() {
          gold24k = decoded['goldsell'];
          gold22k = gold24k*22/24;
          gold18k = gold24k*18/24;
          silverrate = decoded['silversell'];
        });
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  //  Future<void> getCommodityRates() async {
  //   // Simulate fetching commodity rates from an API or database
  //   await Future.delayed(const Duration(seconds: 2));
  //   setState(() {
  //     gold24k = 142000;
  //     gold22k = 130000;
  //     gold18k = 110000;
  //     silverrate = 60000; // Example silver rate
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF102D38);
    const gold = Color(0xFFD39743);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
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
      bottomNavigationBar: Bottombar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TD JEWELLERY  ·  Gold Rate',
                    style: TextStyle(
                      color: gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Live gold rates',
                    style: TextStyle(
                      color: ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the purity you want to compare.',
                    style: TextStyle(
                      color: ink.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _GoldRateTile(label: '24K Gold Rate', value: '${gold24k.toStringAsFixed(2)}'),
            const Divider(height: 1),
            _GoldRateTile(label: '22K Gold Rate', value: '${gold22k.toStringAsFixed(2)}'),
            const Divider(height: 1),
            _GoldRateTile(label: '18K Gold Rate', value: '${gold18k.toStringAsFixed(2)}'),
            const SizedBox(height: 18),
            const Divider(height: 1),
            _GoldRateTile(label: 'Silver Per Kg', value: '${silverrate.toStringAsFixed(2)}'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5C4300).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF5C4300)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rates are indicative and may vary by design, weight, and market conditions.',
                      style: TextStyle(
                        color: Color(0xFF102D38),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldRateTile extends StatelessWidget {
  const _GoldRateTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF102D38),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD39743),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
