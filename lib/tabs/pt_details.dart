import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:qrscan/qrscan.dart' as scanner;
import 'package:encrypt/encrypt.dart' as en;
import 'package:mahospital/constants/controllers.dart';
import 'package:intl/intl.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';

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

  final HttpsCallable dischargeWardPt =
      FirebaseFunctions.instance.httpsCallable(
    'dischargeWardPt',
  );

  Future<void> updateBed() async {
    // await bedRef.doc(currentWPLC.cbm.value.id).update({'ptId': null, 'lastUpdatedBy': uid});
    // var wpm = WardPtModel.fromSnapshot(await pt.get());
    var updatedBedModel =
        BedModel.fromSnapshot(await bedRef.doc(currentWPLC.cbm.value.id).get());
    // await updatedBedModel.getPtModel();
    var index = currentWPLC.currentBML
        .indexWhere((bm) => bm.id == currentWPLC.cbm.value.id);
    currentWPLC.currentBML
        .replaceRange(index, index + 1, [updatedBedModel]); // i come back first
    // if (updatedBedModel.ptInitialised) {
    currentWPLC.cbm.value = updatedBedModel;
    currentWPLC.cwpm.value = WardPtModel();
    //   ptIni = true;
    // }
    // above 2 lines are so that can go to current pt
    // if not initialised how...
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
            child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            margin: EdgeInsets.all(30),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    currentWPLC.cwpm.value.ptDetails(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text('IC: ' + currentWPLC.cwpm.value.icNumber),
                  Text('RN: ' + currentWPLC.cwpm.value.rNos.join(', ')),
                  SizedBox(
                    height: 15,
                  ),
                  ExpansionTile(
                    title: Text('Active Depts'),
                    subtitle: Text(
                        currentWPLC.cwpm.value.activeDepts.length.toString()),
                    children: currentWPLC.cwpm.value.activeDepts.length > 0
                        ? currentWPLC.cwpm.value.activeDepts
                            .map((wm) => ListTile(
                                  title:
                                      new Text(deptListController.deptName(wm)),
                                  // onTap: () => Get.to(WardScreen(wm))
                                ))
                            .toList()
                        : [],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: Text('Discharge'),
                    onPressed: () async {
                      currentWPLC.aptb.value = true;
                      await dischargeWardPt.call(<String, dynamic>{
                        'wardPtId': currentWPLC.cwpm.value.id,
                        'bedId': currentWPLC.cbm.value.id,
                        'dischargeDate':
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        'dischargeById': userController.user.id,
                      }).then((v) async {
                        bool success = v.data as bool;
                        if (success) {
                          Get.back();
                          await updateBed();
                        } else {
                          Get.snackbar(
                            'Error Admitting Pt',
                            'Unable to admit patient to bed',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                          );
                        }
                        currentWPLC.aptb.value = false;
                      }).catchError((e) {
                        Get.snackbar(
                          'Error Admitting Pt',
                          e.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                        );
                        currentWPLC.aptb.value = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        )
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
            ));
  }
}
