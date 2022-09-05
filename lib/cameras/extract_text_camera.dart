import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class ExtractTextCamera extends StatefulWidget {
  final CameraDescription camera;
  // final DeviceOrientation orientation;
  final bool landscape;

  const ExtractTextCamera(
    this.camera,
    this.landscape,
  );

  @override
  ExtractTextCameraState createState() => ExtractTextCameraState();
}

class ExtractTextCameraState extends State<ExtractTextCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

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
    // _controller.lockCaptureOrientation(widget.orientation);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void takePicAndReturnResult(File image) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Credentials')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: FractionalOffset.bottomCenter,
              children: <Widget>[
                Positioned.fill(
                  child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller)),
                ),
                Positioned(
                  width: 60,
                  height: 40,
                  bottom: 40,
                  child: Transform.rotate(
                      angle: widget.landscape ? (-270 * math.pi / 180) : 0,
                      child: ElevatedButton(
                          child: Icon(Icons.camera_alt),
                          onPressed: () async {
                            try {
                              // Ensure that the camera is initialized.
                              await _initializeControllerFuture;
                              // Attempt to take a picture and get the file `image`
                              // where it was saved.
                              final image = await _controller.takePicture();
                              final img.Image? capturedImage =
                                  img.decodeImage(await image.readAsBytes());
                              final img.Image orientedImage = widget.landscape
                                  ? img.copyRotate(capturedImage!, -90)
                                  : capturedImage!;
                              final appDir = await getTemporaryDirectory();
                              File file = await File('${appDir.path}/sth.jpg')
                                  .writeAsBytes(img.encodeJpg(orientedImage));

                              Navigator.pop(
                                context,
                                file.path,
                              );
                            } catch (e) {
                              print(e);
                            }
                          })),
                )
              ],
            );
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
