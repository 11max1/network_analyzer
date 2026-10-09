
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const BlueWaveApp());
}

const blue = Color(0xFF168BFF);
const background = Color(0xFF07111F);
const panel = Color(0xFF111F33);

class BlueWaveApp extends StatelessWidget {
  const BlueWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlueWave WiFi',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          centerTitle: false,
        ),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String deviceIp = 'جارٍ البحث...';
  String connection = 'لم يتم الفحص';
  String latency = '-- ms';
  bool checking = false;

  @override
  void initState() {
    super.initState();
    loadIp();
  }

  Future<void> loadIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      String? found;

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            found = address.address;
            break;
          }
        }
        if (found != null) break;
      }

      if (!mounted) return;
      setState(() {
        deviceIp = found ?? 'غير متاح';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => deviceIp = 'تعذر الحصول عليه');
    }
  }

  Future<void> testConnection() async {
    setState(() {
      checking = true;
      connection = 'جارٍ الفحص...';
      latency = '-- ms';
    });

    final stopwatch = Stopwatch()..start();

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 8));

      stopwatch.stop();

      if (!mounted) return;
      setState(() {
        connection = result.isNotEmpty
            ? 'متصل بالإنترنت'
            : 'تعذر الاتصال';
        latency = result.isNotEmpty
            ? '${stopwatch.elapsedMilliseconds} ms'
            : '-- ms';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        connection = 'فشل الاتصال';
        latency = '-- ms';
      });
    } finally {
      if (mounted) {
        setState(() => checking = false);
      }
    }
  }

  Widget infoCard(
    IconData icon,
    String title,
    String value, {
    Color color = blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.wifi, color: blue, size: 29),
            SizedBox(width: 10),
            Text(
              'BlueWave',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.shield_outlined, color: blue),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'مركز مراقبة الشبكة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'تحليل اتصالك ومعلومات شبكتك',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF145DCE), Color(0xFF12315F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.radar, size: 40),
                  SizedBox(height: 16),
                  Text(
                    'Wi-Fi Network Analyzer',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أدوات الشبكة في مكان واحد',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            infoCard(
              Icons.phone_android,
              'عنوان IP للهاتف',
              deviceIp,
            ),
            const SizedBox(height: 12),
            infoCard(
              Icons.public,
              'حالة الإنترنت',
              connection,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            infoCard(
              Icons.speed,
              'زمن الاستجابة التقريبي',
              latency,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 12),
            infoCard(
              Icons.router,
              'عنوان الراوتر',
              'سنضيفه في المرحلة التالية',
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 12),
            infoCard(
              Icons.signal_wifi_4_bar,
              'قوة إشارة Wi-Fi',
              'بانتظار صلاحيات قراءة Wi-Fi',
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: checking ? null : testConnection,
                icon: checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.network_check),
                label: Text(
                  checking ? 'جارٍ الفحص...' : 'فحص الاتصال',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: loadIp,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث عنوان IP'),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'BlueWave • Network Tools',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}