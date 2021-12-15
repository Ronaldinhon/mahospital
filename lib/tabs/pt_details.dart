import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:qrscan/qrscan.dart' as scanner;
import 'package:encrypt/encrypt.dart' as en;
import 'package:mahospital/constants/controllers.dart';

class PtDetails extends StatefulWidget {
  // final DocumentSnapshot ptData;

  PtDetails();
  @override
  _PtDetailsState createState() => _PtDetailsState();
}

class _PtDetailsState extends State<PtDetails> {
  late String name;
  late String ptIc;
  late String dob;
  late String address;
  late String gender;
  // DocumentSnapshot patData;
  final picker = ImagePicker();
  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  late List<Barcode> barcodes;

  en.IV iv = en.IV.fromLength(16);
  late en.Key enkey;
  late en.Encrypter encrypter;

  @override
  void initState() {
    enkey = en.Key.fromUtf8(currentWPLC.cwpm.value.random32);
    encrypter = en.Encrypter(en.AES(enkey));
    super.initState();
  }

  // void _pickImage() async {
  //   final pickedImage = await picker.pickImage(
  //     source: ImageSource.gallery,
  //   );
  //   // InputImage.fromFile(file);
  //   barcodes = await barcodeScanner
  //       .processImage(InputImage.fromFile(File(pickedImage!.path)));
  //   final String? rawValue = barcodes.first.value.rawValue;
  //   // String first16String = await scanner.scanPath(pickedImage.path);
  //   setCred(rawValue);
  // }

  // void _takePicture() async {
  //   final pickedImage = await picker.pickImage(
  //     source: ImageSource.camera,
  //   );
  //   // String first16String = await scanner.scanPath(pickedImage.path);
  //   barcodes = await barcodeScanner
  //       .processImage(InputImage.fromFile(File(pickedImage!.path)));
  //   final String? rawValue = barcodes.first.value.rawValue;
  //   setCred(rawValue);
  // }

  // void setCred(String? first16) {
  //   final base16 = first16! + currentWPLC.cwpm.value.base16rmd;
  //   var decryed = encrypter.decrypt(en.Encrypted.fromBase16(base16), iv: iv);
  //   Map ptCred = json.decode(decryed);
  //   currentWPLC.cwpm.value.setQrCred(ptCred['name'], ptCred['ptIc']);
  //   setState(() {
  //     name = ptCred['name'];
  //     ptIc = ptCred['ptIc'];
  //     // dob = ptCred['dob'];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currentWPLC.cwpm.value.ptDetails(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text('IC: ' + currentWPLC.cwpm.value.icNumber),
              // SizedBox(
              //   height: 15,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text('Patient Id QR:'),
              //     SizedBox(
              //       width: 15,
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.camera_alt),
              //       onPressed: () => _takePicture(),
              //     ),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.photo),
              //       onPressed: () => _pickImage(),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // Text(currentWPLC.cwpm.value.ptDetails()),
            ],
          ),
        ));
  }
}
