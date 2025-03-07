import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'main.dart'; // Add this import for HomeScreen

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _nameController =
      TextEditingController(text: 'Ben'); // Default username
  final _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _ipController.text = settings.ipAddress;
  }

  void _refreshData() {
    // Find and refresh DashboardScreen and HistoryScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Server IP Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final settings =
                    Provider.of<SettingsProvider>(context, listen: false);
                settings.setCurrentUser(_nameController.text);
                settings.setIpAddress(_ipController.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
