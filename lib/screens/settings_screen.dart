import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController serviceUuidController = TextEditingController();
  final TextEditingController characteristicUuidController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceNameController.text =
          prefs.getString('deviceName') ?? 'LTA Thermometer';
      serviceUuidController.text = prefs.getString('serviceUUID') ?? '180A';
      characteristicUuidController.text =
          prefs.getString('characteristicUUID') ?? '2A29';
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceName', deviceNameController.text.trim());
    await prefs.setString('serviceUUID', serviceUuidController.text.trim());
    await prefs.setString(
        'characteristicUUID', characteristicUuidController.text.trim());
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: deviceNameController,
            decoration: const InputDecoration(labelText: 'Device Name'),
          ),
          TextField(
            controller: serviceUuidController,
            decoration: const InputDecoration(labelText: 'Service UUID'),
          ),
          TextField(
            controller: characteristicUuidController,
            decoration: const InputDecoration(labelText: 'Characteristic UUID'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
    ));
  }
}
