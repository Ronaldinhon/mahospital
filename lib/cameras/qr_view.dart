import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrView extends StatefulWidget {
  final String instruction;

  QrView(this.instruction);
  @override
  _QrViewState createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  late String lol;

  @override
  void initState() {
    // TODO: implement initState
    lol = widget.instruction;
    super.initState();
  }

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('QR Scan'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child:
            // ),
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  borderRadius: 10,
                  borderLength: 20,
                  borderWidth: 10,
                  borderColor: Theme.of(context).primaryColorLight),
            ),
            Positioned(
              bottom: 20,
              child: Text(
                lol,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // Expanded(
            //   flex: 1,
            //   child: Text(lol),
            // )

            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Text(lol),
            //     IconButton(
            //       icon: Icon(Icons.thumb_up),
            //       onPressed: () => Get.back(result: lol),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
  // (result != null)
  //     ? Text(
  //         'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
  //     : Text('Scan a code')

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // setState(() {
      //   result = scanData;
      //   lol = result.code;
      // });
      // Navigator.pop(context, result.code);
      Get.back(result: scanData.code);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
