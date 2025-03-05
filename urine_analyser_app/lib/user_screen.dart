import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map<String, dynamic>? latestData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestResults();
  }

  Future<void> fetchLatestResults() async {
    try {
      final response =
          await http.get(Uri.parse('http://172.20.124.54:5000/lab_results'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          latestData = data.isNotEmpty ? data.first : null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching results: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildBiomarkerCard(String title, dynamic value, String unit,
      String iconPath, String chartPath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset(iconPath, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(title, style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Normal',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value $unit',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(chartPath, height: 40),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (latestData == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(latestData!['username'] ?? 'User'),
            Text(
              latestData!['record_time'] ?? 'No time',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBiomarkerCard('Protein', latestData!['protein'], 'mg/dl',
              'assets/protein-icon.png', 'assets/protein-chart.png'),
          _buildBiomarkerCard(
              'Specific Gravity',
              latestData!['specific_gravity'],
              '',
              'assets/specific-gravity-icon.png',
              'assets/specific-gravity-chart.png'),
          _buildBiomarkerCard('pH', latestData!['ph'], '', 'assets/ph-icon.png',
              'assets/ph-chart.png'),
          _buildBiomarkerCard('Glucose', latestData!['glucose'], 'mg/dl',
              'assets/glucose-icon.png', 'assets/glucose-chart.png'),
          _buildBiomarkerCard('Blood', latestData!['blood'], '',
              'assets/blood-icon.png', 'assets/blood-chart.png'),
        ],
      ),
    );
  }
}
