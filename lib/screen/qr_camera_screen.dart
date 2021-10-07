import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCameraScreen extends StatefulWidget {
  final String instruction;

  QrCameraScreen(this.instruction);
  @override
  _QrCameraScreenState createState() => _QrCameraScreenState();
}

class _QrCameraScreenState extends State<QrCameraScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scan'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(widget.instruction)
              // (result != null)
              //     ? Text(
              //         'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
              //     : Text('Scan a code')
              ,
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      Navigator.pop(context, result.code);
      Get.back(result: 'success');
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
