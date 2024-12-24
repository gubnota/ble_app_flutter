import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Consumer<BleProvider>(
        builder: (context, bleProvider, child) {
          final logData = bleProvider.logMessages;

          if (logData.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: logData.length,
            itemBuilder: (context, index) {
              final message = logData[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      message['timestamp'] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      message['value'] ?? "",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
