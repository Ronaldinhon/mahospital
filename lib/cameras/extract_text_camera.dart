import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ExtractTextCamera extends StatefulWidget {
  final CameraDescription camera;

  const ExtractTextCamera(
    this.camera,
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
        ElevatedButton(
            child: Icon(Icons.camera_alt),
            onPressed: () async {
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Attempt to take a picture and get the file `image`
                // where it was saved.
                final image = await _controller.takePicture();

                Navigator.pop(
                  context,
                  image.path,
                );
              } catch (e) {
                print(e);
              }
            })
      ],
    );
  }
}
