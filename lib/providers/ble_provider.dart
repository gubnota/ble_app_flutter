import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import '../utils/notification_helper.dart';

class BleProvider with ChangeNotifier {
  // State variables
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;

  // Holds log messages with timestamps
  final List<Map<String, String>> _logMessages = [];
  List<Map<String, String>> get logMessages => _logMessages;

  bool _isScanning = false;
  String _connectionStatus = "Disconnected";
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Timer? _readTimer;

  // Public getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  String get connectionStatus => _connectionStatus;

  // Start scanning and connect to the specified BLE device
  Future<void> startScanAndConnect(String targetDeviceName, String serviceUUID,
      String characteristicUUID) async {
    if (_isScanning) return;

    _isScanning = true;
    _connectionStatus = "Scanning...";
    notifyListeners();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (var result in results) {
        if (result.device.platformName.contains(targetDeviceName)) {
          stopScan(); // Stop scanning once device is found
          await connectToDevice(result.device, serviceUUID, characteristicUUID);
          return;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      _connectionStatus = "Failed to Scan";
      print("Scan Error: $e");
      notifyListeners();
    } finally {
      _isScanning = false;
    }
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
    _isScanning = false;
    _scanSubscription?.cancel();
    notifyListeners();
  }

  // Connect to the BLE device
  Future<void> connectToDevice(BluetoothDevice device, String serviceUUID,
      String characteristicUUID) async {
    try {
      _connectionStatus = "Connecting...";
      notifyListeners();

      await device.connect();
      _connectedDevice = device;
      _connectionStatus = "Connected";
      notifyListeners();

      // Discover services and start periodic READ
      await discoverAndMonitorServices(device, serviceUUID, characteristicUUID);
    } catch (e) {
      _connectionStatus = "Failed";
      print("Connection Error: $e");
      notifyListeners();
    }
  }

  // Discover services and periodically read characteristic values
  Future<void> discoverAndMonitorServices(BluetoothDevice device,
      String serviceUUID, String characteristicUUID) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() ==
            serviceUUID.toLowerCase()) {
          print("Service found: ${service.uuid}");

          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                characteristicUUID.toLowerCase()) {
              print("Characteristic found: ${characteristic.uuid}");

              if (characteristic.properties.read) {
                _targetCharacteristic = characteristic;
                _startPeriodicRead(
                    characteristic: characteristic,
                    device: device,
                    service: serviceUUID);
                return;
              } else {
                print(
                    "Characteristic ${characteristic.uuid} does not support READ.");
              }
            }
          }
        }
      }
      print("Target service or characteristic not found.");
    } catch (e) {
      print("Error discovering services: $e");
    }
  }

  // Start periodic READ every 15 seconds
  void _startPeriodicRead(
      {required BluetoothCharacteristic characteristic,
      required BluetoothDevice device,
      required String service}) {
    _readTimer?.cancel(); // Cancel any existing timer

    _readTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        List<int> value = await characteristic.read();
        String hexValue =
            value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
        print("Read Value: $hexValue");

        // Send to Notification Center
        NotificationHelper.showNotification(
            title: device.advName,
            body: "$service:${characteristic.characteristicUuid} = $hexValue");
        // Log the value
        _addLogMessage(
            "${device.advName}:$service\n${characteristic.characteristicUuid} = $hexValue");
      } catch (e) {
        print("Error reading characteristic: $e");
        timer.cancel(); // Stop timer on error
      }
    });
  }

  // Disconnect from the BLE device
  Future<void> disconnect() async {
    try {
      _readTimer?.cancel(); // Stop periodic read timer
      if (_connectedDevice != null) {
        await _connectedDevice?.disconnect();
        _connectedDevice = null;
        _targetCharacteristic = null;
        _connectionStatus = "Disconnected";
        notifyListeners();
      }
    } catch (e) {
      print("Disconnect Error: $e");
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _readTimer?.cancel();
    super.dispose();
  }

  void _addLogMessage(String value) {
    String timestamp = DateTime.now().toString();
    _logMessages.add({
      "timestamp": timestamp,
      "value": value,
    });
    notifyListeners();
  }

  void clearLogs() {
    _logMessages.clear();
    notifyListeners();
  }
}
