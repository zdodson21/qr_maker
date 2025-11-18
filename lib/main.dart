import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // https://pub.dev/packages/qr_flutter
// https://pub.dev/packages/file_selector

void main() {
  runApp(const QrMaker());
}

class QrMaker extends StatelessWidget {
  const QrMaker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Maker',
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
  // QR Code Generation
  String qrData = '';
  bool overCharLimit = false;

  // Image Selection
  String? imgDirectory = '';

  // Options
  bool isGapless = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 320,
              gapless: isGapless,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              
              errorStateBuilder: (cxt, err) {
                return Center(
                  child: Text(
                    'Something went wrong :(',
                    textAlign: TextAlign.center,
                  )
                );
              },
            ),

            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to generate a QR Code',
              ),

              onChanged: (String text) {
                if (text.length < 2330) { // 
                  setState(() {
                    overCharLimit = false;
                    qrData = text;
                  });
                } else {
                  setState(() {
                    overCharLimit = true;
                  });
                }
              },
            ),

            CheckboxListTile(
              title: Text("Gapless"),
              value: isGapless, 
              selected: isGapless,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,

              onChanged: (bool? newValue) {
                if (newValue != null) {
                  setState(() {
                    isGapless = newValue;
                  });
                }
              },
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () {

                  },

                  child: Text('Select Image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      imgDirectory = '';
                    });
                  },

                  child: Text('Clear Image')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
