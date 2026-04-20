import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pinner/pinner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PinningTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PinningTestScreen extends StatefulWidget {
  const PinningTestScreen({super.key});

  @override
  State<PinningTestScreen> createState() => _PinningTestScreenState();
}

class _PinningTestScreenState extends State<PinningTestScreen> {
  final _pinner = Pinner();

  static const String _host = "badssl.com";
  static const List<String> _pins = [
    "chBKGC2E4cdpgMD2jlsFLLJvoujxm9EUKcSlUiZN6Rc=",
  ];

  String _result = "Press button to verify SSL pinning";
  bool _isLoading = false;

  Future<void> checkPinning() async {
    setState(() {
      _isLoading = true;
      _result = "⏳ Verifying...";
    });

    try {
      final isSecure = await _pinner.verify(
        host: _host,
        pins: _pins,
      );

      setState(() {
        _result = isSecure
            ? "✅ Connection Secure (Pin Matched)"
            : "❌ Pin Mismatch";
      });
    } on PlatformException catch (e) {
      setState(() {
        _result = "❌ Error: ${e.message}";
      });
    } catch (e) {
      debugPrint("FULL ERROR: $e");
      setState(() {
        _result = "❌ Unexpected Error";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SSL Pinning Demo")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : checkPinning,
                child: Text(_isLoading ? "Verifying..." : "Check SSL Pinning"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}