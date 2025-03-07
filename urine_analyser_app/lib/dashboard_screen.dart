import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:urine_analyser_app/providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? latestData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchLatestResults();
  }

  Future<void> fetchLatestResults() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final username = context.read<SettingsProvider>().currentUser;
      final baseUrl = context.read<SettingsProvider>().ipAddress;

      final response = await http
          .get(Uri.parse('$baseUrl/lab_results?username=$username'))
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          latestData = data.isNotEmpty ? data.first : null;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: latestData != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(latestData!['username'] ?? 'User'),
                  Text(
                    latestData!['record_time'] ?? 'No time',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            : const Text('Dashboard'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: fetchLatestResults,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : latestData == null
                  ? const Center(child: Text('No data available'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildBiomarkerCard(
                            'Protein',
                            latestData!['protein'],
                            'mg/dl',
                            'assets/protein-icon.png',
                            'assets/protein-chart.png'),
                        _buildBiomarkerCard(
                            'Specific Gravity',
                            latestData!['specific_gravity'],
                            '',
                            'assets/specific-gravity-icon.png',
                            'assets/specific-gravity-chart.png'),
                        _buildBiomarkerCard('pH', latestData!['ph'], '',
                            'assets/ph-icon.png', 'assets/ph-chart.png'),
                        _buildBiomarkerCard(
                            'Glucose',
                            latestData!['glucose'],
                            'mg/dl',
                            'assets/glucose-icon.png',
                            'assets/glucose-chart.png'),
                        _buildBiomarkerCard('Blood', latestData!['blood'], '',
                            'assets/blood-icon.png', 'assets/blood-chart.png'),
                      ],
                    ),
    );
  }
}
