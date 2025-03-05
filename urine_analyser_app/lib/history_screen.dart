import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
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
      final response =
          await http.get(Uri.parse('http://172.20.124.54:5000/lab_results'));
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
        title: Text('Test Details - ${item['date']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${item['time'] ?? 'N/A'}'),
              const Divider(),
              Text('Glucose: ${item['glucose'] ?? 'N/A'} mg/dL'),
              Text('Protein: ${item['protein'] ?? 'N/A'} mg/dL'),
              Text('pH: ${item['ph'] ?? 'N/A'}'),
              // Add more biomarkers as needed
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
                    title: Text('Test ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${item['date'] ?? 'N/A'}'),
                        Text('Time: ${item['time'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDetailsDialog(item),
                  ),
                );
              },
            ),
    );
  }
}
