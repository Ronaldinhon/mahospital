import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:mahospital/constants/controllers.dart';

class FlowChartCamera extends StatefulWidget {
  final CameraDescription camera;

  const FlowChartCamera(this.camera);

  @override
  FlowChartCameraState createState() => FlowChartCameraState();
}

class FlowChartCameraState extends State<FlowChartCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  TextDetector _textDetector = GoogleMlKit.vision.textDetector();
  late RecognisedText regText;
  List<String> idenTexts = [
    'WBC_LINK',
    'HGB',
    'HCT',
    'Sodium',
    'Potassium',
    'Chloride',
    'Urea',
    'Creatinine',
  ];
  Map<String, String> correspondKeys = {
    'WBC_LINK': 'Twc',
    'HGB': 'Hb',
    'HCT': 'Hct',
    'Sodium': 'Na',
    'Potassium': 'K',
    'Chloride': 'Cl',
    'Urea': 'Urea',
    'Creatinine': 'Creat',
  };

  List<NumberWithCoor> numbers = [];
  List<TextWithCoor> identifiers = [];
  Map results = {};
  Map<String, dynamic> goodKeyRes = {};

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void takePicAndReturnResult(File image) {}

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  Future<void> interpret(String path) async {
    // if (path != null) {
    var inputImage = InputImage.fromFilePath(path);
    regText = await _textDetector.processImage(inputImage);
    for (var bl in regText.blocks) {
      if (isNumeric(bl.text)) {
        var coords = bl.cornerPoints.reduce((i, j) => i + j);
        numbers.add(NumberWithCoor(bl.text, coords / 4));
      } else if (idenTexts.contains(bl.text)) {
        var coords = bl.cornerPoints.reduce((i, j) => i + j);
        identifiers.add(TextWithCoor(bl.text, coords / 4));
      }
    }
    if (identifiers.isNotEmpty) {
      for (var iden in identifiers) {
        numbers.sort((a, b) => (a.center.dy - iden.center.dy)
            .abs()
            .compareTo((b.center.dy - iden.center.dy).abs()));
        results[iden.param] = numbers.first.param;
      }
    }
    results.forEach((k, v) {
      goodKeyRes[correspondKeys[k]!] = v;
    });
    // print(goodKeyRes);
    setState(() {});
    // List<String> creds = LineSplitter.split(regText.text).toList();
    // createCards(creds);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Credentials')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: FractionalOffset.center,
              children: <Widget>[
                Positioned.fill(
                  child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller)),
                ),
                // Positioned.fill(
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Opacity(
                //       opacity: 1,
                //       child: Image.network(
                //         'https://cdn4.iconfinder.com/data/icons/famous-sports/64/famous_sports_32-512.png',
                //         fit: BoxFit.fitWidth,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: () {
            ecController.ixResults.addAll(goodKeyRes);
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(results.toString())),
        ),
        ElevatedButton(
            child: Icon(Icons.camera_alt),
            onPressed: () async {
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Attempt to take a picture and get the file `image`
                // where it was saved.
                final image = await _controller.takePicture();

                // Navigator.pop(
                //   context,
                //   image.path,
                // );
                interpret(image.path);
              } catch (e) {
                print(e);
              }
            })
      ],
    );
  }
}

class TextWithCoor {
  String param;
  Offset center;
  TextWithCoor(this.param, this.center);
}

class NumberWithCoor {
  String param;
  Offset center;
  NumberWithCoor(this.param, this.center);
}
