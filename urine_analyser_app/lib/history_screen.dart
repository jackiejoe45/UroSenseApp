import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final username = context.read<SettingsProvider>().currentUser;
      final response = await http.get(
          Uri.parse('${context.read<SettingsProvider>().ipAddress}/lab_results?username=$username'));
      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching history: $e');
      setState(() => isLoading = false);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(item['username'] ?? 'N/A'),
                    subtitle: Text(item['record_time'] ?? 'N/A'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDetailsDialog(item),
                  ),
                );
              },
            ),
    );
  }
}
