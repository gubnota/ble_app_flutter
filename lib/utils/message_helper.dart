import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<BleProvider>(context, listen: false).clearLogs();
            },
            tooltip: "Clear Logs",
          ),
        ],
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
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      message['timestamp']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      message['value']!,
                      style: const TextStyle(color: Colors.black87),
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
