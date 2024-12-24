import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/ble_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String serviceUUID = "180A"; // Default
  String characteristicUUID = "2A29"; // Default

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      serviceUUID = prefs.getString('serviceUUID') ?? "180A";
      characteristicUUID = prefs.getString('characteristicUUID') ?? "2A29";
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () async {
            if (bleProvider.connectionStatus == "Connected") {
              await bleProvider.disconnect();
            } else if (!bleProvider.isScanning) {
              await bleProvider.startScanAndConnect(
                "LTA Thermometer",
                serviceUUID,
                characteristicUUID,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(bleProvider.connectionStatus),
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                _getButtonText(
                    bleProvider.connectionStatus, bleProvider.isScanning),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Determine button text
  String _getButtonText(String status, bool isScanning) {
    if (status == "Connected") return "Disconnect";
    if (isScanning) return "Scanning...";
    return "Connect";
  }

  // Determine border color dynamically
  Color _getBorderColor(String status) {
    switch (status) {
      case "Connected":
        return Colors.green;
      case "Scanning...":
        return Colors.blue;
      case "Failed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
