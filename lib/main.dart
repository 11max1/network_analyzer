import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const NetworkAnalyzerApp());
}

class NetworkAnalyzerApp extends StatelessWidget {
  const NetworkAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = 'اضغط على فحص الاتصال';
  String ipAddress = 'غير معروف';

  Future<void> checkConnection() async {
    setState(() {
      status = 'جاري الفحص...';
    });

    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty) {
        setState(() {
          status = 'متصل بالإنترنت ✓';
        });
      }
    } catch (_) {
      setState(() {
        status = 'لا يوجد اتصال';
      });
    }
  }

  Future<void> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 &&
              !address.isLoopback) {
            setState(() {
              ipAddress = address.address;
            });
            return;
          }
        }
      }
    } catch (_) {
      setState(() {
        ipAddress = 'تعذر الحصول على IP';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLocalIp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Analyzer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.router,
              size: 90,
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('عنوان IP'),
                subtitle: Text(ipAddress),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi),
                title: const Text('حالة الإنترنت'),
                subtitle: Text(status),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: checkConnection,
                icon: const Icon(Icons.network_check),
                label: const Text('فحص الاتصال'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: getLocalIp,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث IP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}