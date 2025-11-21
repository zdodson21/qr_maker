import 'dart:io';
import 'package:file_picker/file_picker.dart'; // https://pub.dev/packages/file_picker
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // https://pub.dev/packages/qr_flutter

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // QR Code Generation
  String qrData = '';
  bool overCharLimit = false;

  // Image Selection
  String imgDirectory = '';

  // Options
  bool isGapless = true;
  bool useCornerCircles = false;
  bool useDataCircles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              // Data
              data: qrData,
              version: QrVersions.auto,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              embeddedImage: FileImage(File(imgDirectory)),
              semanticsLabel: 'Q R code for: $qrData',

              // Styles
              size: 320,
              gapless: isGapless,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                color: Colors.black,
                eyeShape: useCornerCircles ? QrEyeShape.circle : QrEyeShape.square,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: Colors.black,
                dataModuleShape: useDataCircles ? QrDataModuleShape.circle : QrDataModuleShape.square
              ),
            ),

            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Text to Generate a QR Code',
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
            
            Column( // Configuration Checkboxes
              children: [
                CheckboxListTile(
                  title: Text("Gapless"),
                  value: isGapless, 
                  selected: isGapless,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,

                  onChanged: (bool? checked) {
                    if (checked != null) {
                      setState(() {
                        isGapless = checked;
                      });
                    }
                  },
                ),

                CheckboxListTile(
                  title: Text("Use Circles at Corners"),
                  value: useCornerCircles,
                  selected: useCornerCircles,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,

                  onChanged:(bool? checked) {
                    if (checked != null) {
                      setState(() {
                        useCornerCircles = checked;
                      });
                    }
                  },
                ),

                CheckboxListTile(
                  title: Text("Use Circles for Data"),
                  value: useDataCircles, 
                  selected: useCornerCircles,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,

                  onChanged: (bool? checked) {
                    if (checked != null) {
                      setState(() {
                        useDataCircles = checked;
                      });
                    }
                  }
                ),
              ]
            ),

            Row( // Image Buttons
              children: [
                ElevatedButton(
                  child: Text('Select Image'),

                  onPressed: () async {
                    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image,);

                    if (result != null) {
                      setState(() {
                        imgDirectory = result.files.single.path!;
                      });
                    }
                  },
                ),

                ElevatedButton(
                  child: Text('Clear Image'),
                  
                  onPressed: () {
                    setState(() {
                      imgDirectory = '';
                    });
                  },
                )
              ],
            ),

            ElevatedButton(
              child: Text('Save QR Code as Image'),

              onPressed: () {

              }, 
            ),
          ],
        ),
      ),
    );
  }
}
