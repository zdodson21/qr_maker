import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart'; // https://pub.dev/packages/dynamic_color
import 'package:file_picker/file_picker.dart'; // https://pub.dev/packages/file_picker
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // https://pub.dev/packages/path_provider
import 'package:permission_handler/permission_handler.dart'; // https://pub.dev/packages/permission_handler
import 'package:qr_flutter/qr_flutter.dart'; // https://pub.dev/packages/qr_flutter
import 'package:screenshot/screenshot.dart'; // https://pub.dev/packages/screenshot/install
import 'package:shared_preferences/shared_preferences.dart'; // https://pub.dev/packages/shared_preferences/install

void main() {
  runApp(const QrMaker());
}

// TODO ensure Windows works
// TODO check pubspec.yaml, remove any unused packages.

class QrMaker extends StatelessWidget {
  const QrMaker({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme fallbackLight = ColorScheme.fromSeed(
          seedColor: Colors.amber, 
          brightness: Brightness.light
        );

        final ColorScheme fallbackDark = ColorScheme.fromSeed(
          seedColor: Colors.amber, 
          brightness: Brightness.dark,
        );
        
        return MaterialApp(
          title: 'QR Maker',
          theme: ThemeData(
            colorScheme: lightDynamic ?? fallbackLight,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? fallbackDark,
            scaffoldBackgroundColor: Colors.black
          ),
          themeMode: ThemeMode.system,
          home: const MyHomePage(),
        );
      },
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

  @override
  void initState() {
    _getQrList();
    super.initState();
  }

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

  /// Gets QR code list data using SharedPreferences
  void _getQrList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('qr_list');

    if (list != null) {
      setState(() {
        qrList = list;
      });
    }
  }

  /// Adds item to QR code list
  void _addQrListItem(String newItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (newItem != '') {
      setState(() {
        qrList.add(newItem);
        qrList.sort();
      });
    }

    await prefs.setStringList('qr_list', qrList);
  }

  /// Removes item from QR code list
  void _removeQrListItem(String removableItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (qrList.contains(removableItem)) {
      setState(() {
        qrList.remove(removableItem);
        qrList.sort();

        qrData = '';

        _setTextField(qrData);
      });

      await prefs.setStringList('qr_list', qrList);
    }
  }

  /// Sets text field based on provided value
  void _setTextField(String value) {
    _controller.value = _controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length)
    );
  }

  void _snackBarMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Screenshot(
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
            ),
            

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedButton(
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
            ),

            if (selectedOption == 'text')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
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
                          enableSuggestions: false,
                        ),
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        child: Icon(Icons.save),
                                      
                        onPressed: () {
                          try {
                            if (qrData != '') {
                              _addQrListItem(qrData);
                              _snackBarMessage('Saved QR code to list!');
                            } else {
                              _snackBarMessage('Will not save blank string to list!');
                            }
                          } catch (e) {
                            _snackBarMessage('Failed to save qr code to list: $e');
                          }
                        }, 
                      ),
                    ),
                  ],
                ),
              ),
            
            if (selectedOption == 'select')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownMenu(
                        onSelected: (value) {
                          if (value != null) {
                            setState(() {
                              qrData = value;
                            });
                                    
                            _setTextField(value);
                          }
                        },
                      
                        dropdownMenuEntries: qrList.map((item) {
                          return DropdownMenuEntry(
                            value: item, 
                            label: item,
                          );
                        }).toList(),
                        requestFocusOnTap: false,
                      ),
                    ),
                    
                    ElevatedButton(
                      child: Icon(Icons.delete),
                
                      onPressed: () {
                        _removeQrListItem(qrData);
                      }, 
                    ),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(// Configuration Checkboxes
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
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row( // Image Buttons
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ElevatedButton(
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
                  ),
              
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: ElevatedButton(
                      child: Text('Clear Image'),
                      
                      onPressed: () {
                        setState(() {
                          imgDirectory = '';
                        });
                      },
                    ),
                  )
                ],
              ),
            ),

            if (!Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('Save QR Code as Image'),
                    
                      onPressed: () async {
                        try {
                          // TODO I think file permission is needed, but cannot find any reliable sources for how to do this.
                
                          DateTime now = DateTime.now();
                          String fileName = 'QRMaker-${now.month}-${now.day}-${now.year}-${now.hour}:${now.minute}:${now.second}.png';
                          
                          // "runtime permissions"
                          String? dir = await FilePicker.platform.getDirectoryPath();
                
                          if (dir == null) {
                            _snackBarMessage('No directory selected');
                
                            return;
                          }
                          
                          await screenshotController.captureAndSave(
                            dir,
                            fileName: fileName
                          );
                    
                          _snackBarMessage('QR code saved to $dir successfully!');
                        } catch (e) {
                          _snackBarMessage('Failed to save QR code: $e');
                        }
                      }, 
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
