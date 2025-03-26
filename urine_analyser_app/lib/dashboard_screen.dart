import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:urine_analyser_app/providers/settings_provider.dart';

class BiomarkerInfo {
  final String name;
  final String normalRange;
  final String caution;
  final String danger;

  BiomarkerInfo({
    required this.name,
    required this.normalRange,
    required this.caution,
    required this.danger,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? latestData;
  bool isLoading = true;
  String? error;

  final Map<String, BiomarkerInfo> biomarkerDetails = {
    'Glucose': BiomarkerInfo(
      name: 'Glucose',
      normalRange: '0 to 15 mg/dL',
      caution:
          'Levels between 15 and 100 mg/dL – Keep an eye on your diet and hydration; if this persists, consider rechecking with your provider.',
      danger:
          'Levels above 100 mg/dL – High glucose in urine may indicate issues such as uncontrolled blood sugar or gestational diabetes. It\'s advisable to seek further evaluation.',
    ),
    'pH': BiomarkerInfo(
      name: 'pH',
      normalRange: '4.6 to 8.0',
      caution:
          'pH slightly below 4.6 (down to 4.0) or just above 8.0 (up to 8.5) – Minor deviations can be influenced by diet or hydration. Monitor these changes and adjust fluid intake if needed.',
      danger:
          'pH below 4.0 or above 8.5 – Significant deviations could indicate metabolic or renal concerns and may require professional assessment.',
    ),
    'Protein': BiomarkerInfo(
      name: 'Protein',
      normalRange: '0 to 14 mg/dL',
      caution:
          'Levels from 14 to 30 mg/dL – A moderate increase might be a sign to recheck kidney function or adjust dietary protein intake.',
      danger:
          'Levels above 30 mg/dL – Elevated protein may point to kidney damage or other underlying issues. It is important to follow up with a healthcare professional for further evaluation.',
    ),
    'Blood': BiomarkerInfo(
      name: 'Blood',
      normalRange: 'Not detected or 0',
      caution:
          'Trace amounts (for example, values between 1 and 50) – Minor blood traces might occur due to exercise or minor irritation.',
      danger:
          'Higher levels (above 50) – Significant detection of blood can indicate infections, kidney stones, or other urinary tract issues. Consider further investigation.',
    ),
    'Specific Gravity': BiomarkerInfo(
      name: 'Specific Gravity',
      normalRange: '1.010 to 1.030',
      caution:
          'Values slightly below 1.010 or between 1.030 and 1.040 – These could be due to overhydration or mild dehydration. Adjust your fluid intake and monitor your hydration status.',
      danger:
          'Values outside these caution limits (below 1.000 or above 1.040) – Extreme concentrations may signal severe hydration imbalances or kidney function issues and should be evaluated further.',
    ),
  };

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

  Widget _buildCard(String title, String value, String unit, String iconPath,
      String chartPath, String statusText, Color statusColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(iconPath, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Flexible(
                          child: Text(title,
                              style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusText,
                      style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$value $unit',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBiomarkerCard(String title, dynamic value, String unit,
      String iconPath, String chartPath) {
    String statusText;
    Color statusColor;

    // Handle null, invalid or string values
    if (value == null || value.toString().isEmpty || value is String) {
      statusText = 'Unknown';
      statusColor = Colors.grey;
      return _buildCard(title, value?.toString() ?? 'N/A', unit, iconPath,
          chartPath, statusText, statusColor);
    }

    // Convert to double for numeric comparison
    double numValue;
    try {
      numValue = double.parse(value.toString());
    } catch (e) {
      statusText = 'Unknown';
      statusColor = Colors.grey;
      return _buildCard(title, value.toString(), unit, iconPath, chartPath,
          statusText, statusColor);
    }

    // Rest of your existing status checks using numValue
    if (title == 'Glucose') {
      if (numValue < 0 || numValue > 1000) {
        statusText = 'Unknown';
        statusColor = Colors.grey;
      } else if (numValue < 15) {
        statusText = 'Normal';
        statusColor = Colors.green;
      } else if (numValue < 100) {
        statusText = 'Caution';
        statusColor = Colors.yellow;
      } else {
        statusText = 'Danger';
        statusColor = Colors.red;
      }
    } else if (title == 'pH') {
      if (numValue < 0 || numValue > 14) {
        // pH scale limits
        statusText = 'Unknown';
        statusColor = Colors.grey;
      } else if (numValue >= 4.6 && numValue <= 8.0) {
        statusText = 'Normal';
        statusColor = Colors.green;
      } else if ((numValue < 4.6 && numValue >= 4.0) ||
          (numValue > 8.0 && numValue <= 8.5)) {
        statusText = 'Caution';
        statusColor = Colors.yellow;
      } else {
        statusText = 'Danger';
        statusColor = Colors.red;
      }
    } else if (title == 'Protein') {
      if (numValue < 0 || numValue > 2000) {
        // Unrealistic values
        statusText = 'Unknown';
        statusColor = Colors.grey;
      } else if (numValue <= 14) {
        statusText = 'Normal';
        statusColor = Colors.green;
      } else if (numValue <= 30) {
        statusText = 'Caution';
        statusColor = Colors.yellow;
      } else {
        statusText = 'Danger';
        statusColor = Colors.red;
      }
    } else if (title == 'Blood') {
      if (numValue < 0 || numValue > 200) {
        // Unrealistic values
        statusText = 'Unknown';
        statusColor = Colors.grey;
      } else if (numValue == 0) {
        statusText = 'Normal';
        statusColor = Colors.green;
      } else if (numValue <= 50) {
        statusText = 'Caution';
        statusColor = Colors.yellow;
      } else {
        statusText = 'Danger';
        statusColor = Colors.red;
      }
    } else if (title == 'Specific Gravity') {
      if (numValue < 1.000 || numValue > 1.050) {
        // Unrealistic values
        statusText = 'Unknown';
        statusColor = Colors.grey;
      } else if (numValue >= 1.010 && numValue <= 1.030) {
        statusText = 'Normal';
        statusColor = Colors.green;
      } else if ((numValue < 1.010 && numValue >= 1.000) ||
          (numValue > 1.030 && numValue <= 1.040)) {
        statusText = 'Caution';
        statusColor = Colors.yellow;
      } else {
        statusText = 'Danger';
        statusColor = Colors.red;
      }
    } else {
      statusText = 'Unknown';
      statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        _showBiomarkerDetails(title);
      },
      child: Card(
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
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: statusColor, fontSize: 12),
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
      ),
    );
  }

  void _showBiomarkerDetails(String title) {
    final biomarkerInfo = biomarkerDetails[title];

    if (biomarkerInfo != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(biomarkerInfo.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${_getStatus(title, latestData?[title])}',
                  style: TextStyle(
                      color: _getStatusColor(title, latestData?[title]))),
              const SizedBox(height: 8),
              Text('Normal Range: ${biomarkerInfo.normalRange}'),
              const SizedBox(height: 8),
              Text('Caution: ${biomarkerInfo.caution}'),
              const SizedBox(height: 8),
              Text('Danger: ${biomarkerInfo.danger}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  String _getStatus(String biomarker, dynamic value) {
    double numValue = double.tryParse(value.toString()) ?? -1;

    // Implement status checks based on numValue
    if (numValue < 0) {
      return 'Unknown';
    } else if (numValue < 15) {
      return 'Normal';
    } else if (numValue < 100) {
      return 'Caution';
    } else {
      return 'Danger';
    }
  }

  Color _getStatusColor(String biomarker, dynamic value) {
    String status = _getStatus(biomarker, value);
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Caution':
        return Colors.yellow;
      case 'Danger':
        return Colors.red;
      default:
        return Colors.grey; // For 'Unknown' or any other case
    }
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
