import 'dart:io';
import 'package:file_picker/file_picker.dart'; // https://pub.dev/packages/file_picker
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // https://pub.dev/packages/path_provider
import 'package:permission_handler/permission_handler.dart'; // https://pub.dev/packages/permission_handler
import 'package:qr_flutter/qr_flutter.dart'; // https://pub.dev/packages/qr_flutter
import 'package:screenshot/screenshot.dart'; // https://pub.dev/packages/screenshot/install

void main() {
  runApp(const QrMaker());
}

// TODO advanced options:
// TODO File naming box (clear button as well)
// TODO set deafult file path with button, display the file path, have option to change it. Display a "Save to default" button if it is set.

// TODO check pubspec.yaml, remove any unused packages.

class QrMaker extends StatelessWidget {
  const QrMaker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Maker',
      theme: ThemeData( // TODO if possible get material you chosen color from android, else use a default (amber?)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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
  List<String> qrList = [];

  // Image Selection
  String imgDirectory = '';

  // Options
  String selectedOption = 'text';
  bool isGapless = true;
  bool useCornerCircles = false;
  bool useDataCircles = false;

  // Controllers 
  ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Screenshot(
              controller: screenshotController,
              
              child: 
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
            ),
            

            SegmentedButton(
              segments: [
                ButtonSegment(value: 'text', label: Text('Text'), icon: Icon(Icons.keyboard)),
                ButtonSegment(value: 'select', label: Text('Select'), icon: Icon(Icons.menu)),
              ], 

              selected: {selectedOption},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedOption = newSelection.first;
                });
              },
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      label: Text("QR Code Data Field"),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Text to Generate a QR Code',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                  
                          setState(() {
                            qrData = '';
                          });
                        },
                      )
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
                ),

                ElevatedButton(
                  child: Icon(Icons.save),

                  onPressed: () {
                    setState(() {
                      if (qrData != '') {
                        qrList.add(qrData);
                      }
                      qrList.sort();
                    });
                  }, 
                ),
              ],
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('Insert Image'),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('Save QR Code as Image'),
                
                  onPressed: () async {
                    try {
                      if ((Platform.isAndroid || Platform.isIOS)) {
                        PermissionStatus storagePermissionStat = await Permission.storage.status;
                        
                        if (storagePermissionStat.isDenied) await Permission.storage.request(); // Request permission

                        if (storagePermissionStat.isPermanentlyDenied) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Storage permission permanently denied. Please change storage permission. in your settings app.'))
                            );
                          }

                          return;
                        } else if (storagePermissionStat.isDenied) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Storage permission denied. Please grant storage permission.'))
                            );
                          }

                          return;
                        }
                      }

                      DateTime now = DateTime.now();
                      String fileName = 'QRMaker-${now.month}-${now.day}-${now.year}-${now.hour}:${now.minute}:${now.second}.png';
                      
                      // "runtime permissions"
                      String? dir = await FilePicker.platform.getDirectoryPath();

                      if (dir == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No directory selected.'))
                          );
                        }

                        return;
                      }
                      
                      await screenshotController.captureAndSave(
                        dir,
                        fileName: fileName
                      );
                
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("QR Code saved to $dir successfully!")),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to save QR code: $e"))
                        );
                      }
                    }
                  }, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
