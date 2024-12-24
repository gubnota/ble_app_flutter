import 'package:ble_app/providers/ble_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/settings_screen.dart';
import 'package:provider/provider.dart';

import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initNotifications();
  runApp(ChangeNotifierProvider(
    create: (context) => BleProvider(),
    child: const BLEApp(),
  ));
  // runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      color: Colors.white,
      home: const BLEAppHome(),
    );
  }
}

class BLEAppHome extends StatefulWidget {
  const BLEAppHome({super.key});

  @override
  State<BLEAppHome> createState() => _BLEAppHomeState();
}

class _BLEAppHomeState extends State<BLEAppHome> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const MessagesScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
