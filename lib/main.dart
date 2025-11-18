import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const QrMaker());
}

class QrMaker extends StatelessWidget {
  const QrMaker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'QR Code Maker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String qrData = '';
  bool isGapless = false; // TODO not setting currently, might be a scope issue, check demo to see how this thing is done there.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: 'Test',
              version: QrVersions.auto,
              size: 320,
              gapless: isGapless,
            ),
            
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to generate a QR Code'
              ),
            ),
            // Add Checkbox here for gapless
          ],
        ),
      ),
    );
  }
}
