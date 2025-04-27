import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:urine_analyser_app/providers/settings_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> historyData = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final username = context.read<SettingsProvider>().currentUser;
      final baseUrl = context.read<SettingsProvider>().ipAddress;
      print('Fetching history from: $baseUrl/history?username=$username');

      final response = await http
          .get(Uri.parse('$baseUrl/history?username=$username'))
          .timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          print('Request timed out');
          throw TimeoutException(
              'Connection timed out. Please check your network connection.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Decoded data length: ${data.length}');
        if (!mounted) return;
        setState(() {
          historyData = data;
          isLoading = false;
          error = null;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          error =
              'Server error: ${response.statusCode}\nBody: ${response.body}';
        });
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching history: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Details\n${item['record_time'] ?? 'N/A'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Username: ${item['username'] ?? 'N/A'}'),
              const Divider(),
              Text('Glucose: ${item['glucose'] ?? 'N/A'} mg/dL'),
              Text('Protein: ${item['protein'] ?? 'N/A'} mg/dL'),
              Text('pH: ${item['ph'] ?? 'N/A'}'),
              Text('Blood: ${item['blood'] ?? 'N/A'}'),
              Text('Ketones: ${item['ketones'] ?? 'N/A'}'),
              Text('Nitrite: ${item['nitrite'] ?? 'N/A'}'),
              Text('Leukocytes: ${item['leukocytes'] ?? 'N/A'}'),
              Text('Specific Gravity: ${item['specific_gravity'] ?? 'N/A'}'),
              Text('Bilirubin: ${item['bilirubin'] ?? 'N/A'}'),
              Text('Urobilinogen: ${item['urobilinogen'] ?? 'N/A'} µmol/L'),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.blue,
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: fetchHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyData.isEmpty
                  ? const Center(child: Text('No history data available'))
                  : RefreshIndicator(
                      onRefresh: fetchHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          final item = historyData[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title:
                                  Text('Test Result - ${item['record_time']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Glucose: ${item['glucose']} mg/dL'),
                                  Text('Protein: ${item['protein']} mg/dL'),
                                  Text('pH: ${item['ph']}'),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showDetailsDialog(item),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
