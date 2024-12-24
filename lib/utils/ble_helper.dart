import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEHelper {
  static Future<bool> checkPermissions() async {
    // Request Bluetooth permissions
    if (await Permission.bluetooth.status.isDenied ||
        await Permission.bluetoothScan.status.isDenied ||
        await Permission.locationWhenInUse.status.isDenied) {
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
      await Permission.locationWhenInUse.request();
    }

    // Check if permissions are granted
    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.locationWhenInUse.isGranted) {
      return true;
    }

    print('Permissions not granted');
    return false;
  }

  static Future<void> scanForDevices(
      Function(BluetoothDevice) onDeviceFound) async {
    if (!await checkPermissions()) {
      print('Permissions not granted, scan aborted');
      return;
    }

    print('Starting BLE Scan...');
    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.platformName.contains("LTA Thermometer")) {
          FlutterBluePlus.stopScan();
          onDeviceFound(result.device);
          break;
        }
      }
    }).onError((error) {
      print("Error during scan: $error");
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print('Error during scan: $e');
    }
  }
}
