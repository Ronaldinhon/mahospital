import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  en.IV iv = en.IV.fromLength(16);
  late en.Key enkey;
  late en.Encrypter encrypter;
  bool dischargingPt = false;
  // late String uid;

  @override
  void initState() {
    enkey = en.Key.fromUtf8(currentWPLC.cwpm.value.random32);
    encrypter = en.Encrypter(en.AES(enkey));
    // uid = auth.currentUser!.uid;
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

  final HttpsCallable changeBed = FirebaseFunctions.instance.httpsCallable(
    'changeBed',
  );

  final HttpsCallable discDept = FirebaseFunctions.instance.httpsCallable(
    'discDept',
  );

  Future<QuerySnapshot<Object?>> getActiveEmptyBedList() {
    return bedRef
        .where('wardId', isEqualTo: currentWPLC.cbm.value.wardId)
        .where('active', isEqualTo: true)
        .where('ptId', isNull: true)
        .get();
  }

  late QueryDocumentSnapshot aBed;
  bool changingBed = false;

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
            margin: EdgeInsets.all(18),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    currentWPLC.cwpm.value.ptDetails(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                        dividerTheme: DividerThemeData(
                            color: Colors.black, thickness: 2)),
                    child: ExpansionTile(
                      title: Text('Pt Details'),
                      children: [
                        TextFormField(
                          controller: currentWPLC.cpName,
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpIc,
                          decoration: InputDecoration(
                            labelText: 'Ic',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpDOB,
                          decoration: InputDecoration(
                            labelText: 'DOB',
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ToggleButtons(
                          children: <Widget>[
                            Icon(Icons.male),
                            Icon(Icons.female),
                            Icon(Icons.transgender),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < currentWPLC.isSelected.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  currentWPLC.isSelected[buttonIndex] = true;
                                } else {
                                  currentWPLC.isSelected[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: currentWPLC.isSelected,
                        ),
                        TextFormField(
                          controller: currentWPLC.cpRace,
                          decoration: InputDecoration(
                            labelText: 'Race',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpRNnos,
                          decoration: InputDecoration(
                            labelText: 'RN nos.',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpaAts,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Admitted at',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpdAts,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Discharged at',
                          ),
                        ),
                        TextFormField(
                          controller: currentWPLC.cpAdd,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Address',
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        currentWPLC.updatingPt.value
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                child: Text('Update'),
                                onPressed: () => currentWPLC.updatePtDetails(),
                              ),
                        SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  ),
                  // Text('IC: ' + currentWPLC.cwpm.value.icNumber),
                  // Text('RN: ' + currentWPLC.cwpm.value.rNos.join(', ')),
                  SizedBox(
                    height: 10,
                  ),
                  ExpansionTile(
                    title: Text('Active Depts'),
                    subtitle: Text(
                        currentWPLC.cwpm.value.activeDepts.length.toString()),
                    children: currentWPLC.cwpm.value.activeDepts.length > 0
                        ? currentWPLC
                            .cwpm.value.activeDepts // is this alread in Obx?
                            .map((wmId) => ListTile(
                                  title: new Text(
                                      deptListController.deptName(wmId)),
                                  trailing: !deptListController
                                          .deptModel(wmId)
                                          .members
                                          .contains(auth.currentUser!.uid)
                                      ? Container()
                                      : ElevatedButton(
                                          child: Text('Disc'),
                                          onPressed: () async => await discDept
                                              .call(<String, dynamic>{
                                            'wardPtId':
                                                currentWPLC.cwpm.value.id,
                                            'deptId': wmId,
                                          }).then((v) async {
                                            int suck = v.data as int;
                                            print(suck);
                                            currentWPLC.discDept(wmId);
                                            Get.snackbar(
                                              'Success',
                                              'Patient discharged from' +
                                                  deptListController
                                                      .deptName(wmId),
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                            );
                                          }).catchError((e) {
                                            Get.snackbar(
                                              'Error Discharging Patient',
                                              e.toString(),
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                            );
                                          }),
                                        ),
                                ))
                            .toList()
                        : [],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  dischargingPt
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          child: Text('Discharge'),
                          onPressed: () async {
                            setState(() => dischargingPt = true);
                            await dischargeWardPt.call(<String, dynamic>{
                              'wardPtId': currentWPLC.cwpm.value.id,
                              'bedId': currentWPLC.cbm.value.id,
                              'dischargeDate': DateFormat('dd/MM/yyyy')
                                  .format(DateTime.now()),
                              'dischargeById': userController.user.id,
                            }).then((v) async {
                              bool success = v.data as bool;
                              if (success) {
                                Get.back();
                                await updateBed();
                              } else {
                                Get.snackbar(
                                  'Error Discharging Patient',
                                  'Unable to discharge patient from bed',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                );
                              }
                              setState(() => dischargingPt = false);
                            }).catchError((e) {
                              Get.snackbar(
                                'Error Discharging Patient',
                                e.toString(),
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                              );
                              setState(() => dischargingPt = false);
                            });
                          },
                        ),
                  SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    child: Text('Change Bed'),
                    onPressed: () async {
                      await Get.defaultDialog(
                          title: 'Change Bed',
                          contentPadding: EdgeInsets.all(15.0),
                          content: FutureBuilder<QuerySnapshot<Object?>>(
                              future: getActiveEmptyBedList(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot<Object?>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Column(
                                    children: [
                                      // Text('Change to:'),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      DropdownButtonFormField<
                                          QueryDocumentSnapshot>(
                                        decoration: InputDecoration(
                                          hoverColor:
                                              Theme.of(context).primaryColor,
                                          labelText: 'Avalilable Bed',
                                        ),
                                        onChanged:
                                            (QueryDocumentSnapshot<Object?>?
                                                _) {
                                          aBed = _!;
                                        },
                                        items: snapshot.data?.docs
                                            .map((QueryDocumentSnapshot value) {
                                          return DropdownMenuItem<
                                                  QueryDocumentSnapshot>(
                                              value: value,
                                              child:
                                                  // ConstrainedBox(
                                                  //     constraints: BoxConstraints(
                                                  //         maxWidth:
                                                  //             MediaQuery.of(context)
                                                  //                     .size
                                                  //                     .width *
                                                  //                 0.7),
                                                  //     child:
                                                  Text(value.get('name'))
                                              // ),
                                              );
                                        }).toList(),
                                      ),
                                      changingBed
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              child: Text('Confirm'),
                                              onPressed: () async {
                                                setState(
                                                    () => changingBed = true);
                                                await changeBed
                                                    .call(<String, dynamic>{
                                                  'userId':
                                                      auth.currentUser!.uid,
                                                  'wardPtId':
                                                      currentWPLC.cwpm.value.id,
                                                  'oldBedId':
                                                      currentWPLC.cbm.value.id,
                                                  'newBedId': aBed.id,
                                                }).then((v) {
                                                  bool success = v.data as bool;
                                                  if (success) {
                                                    Get.back();
                                                    Get.snackbar('Bed Changed',
                                                        'Please refresh beds in ward',
                                                        backgroundColor:
                                                            Colors.green,
                                                        duration: Duration(
                                                            seconds: 2));
                                                  } else {
                                                    Get.snackbar('Failed',
                                                        'Could not proceed with bed change',
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration: Duration(
                                                            seconds: 2));
                                                  }
                                                  setState(() =>
                                                      changingBed = false);
                                                }).catchError((e) {
                                                  print(e);
                                                  Get.snackbar(
                                                    'Error Changing Bed',
                                                    e.toString(),
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                  );
                                                  setState(() =>
                                                      changingBed = false);
                                                });
                                              },
                                            )
                                    ],
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }));
                    },
                  )
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
