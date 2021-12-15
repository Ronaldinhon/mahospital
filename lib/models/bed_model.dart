import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/ward_pt_model.dart';

import 'hosp_model.dart';

class BedModel {
  late String id;
  late String name;
  late bool active;
  late bool o2;
  // late bool occupied; // need?
  late String hospId;
  late String deptId;
  late String wardId;
  late String lastUpdatedBy;
  late String ptId;
  late WardPtModel wardPtModel;
  bool ptInitialised = false;
  bool error = false;

  BedModel();

  BedModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      name = snapshot.get('name');
      active = snapshot.get('active');
      o2 = snapshot.get('o2');
      hospId = snapshot.get('hospId');
      deptId = snapshot.get('deptId');
      wardId = snapshot.get('wardId');
      ptId = snapshot.get('ptId') ?? ''; //work? should work ba
      lastUpdatedBy = snapshot.get('lastUpdatedBy');
      id = snapshot.id;
      // if (ptId.isNotEmpty) getPtModel(); // not yet create wardPt in firebase
    } catch (e) {
      Get.snackbar(
        "Error retrieving bed data",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<WardPtModel> getPtModel() async {
    // DocumentSnapshot<Object?> wpo = await wardPtRef.doc(ptId).get();
    // try {
    //   if (ptId.isNotEmpty) {
        // wardPtModel = await allWardPtListController.createAndReturn(ptId);
        wardPtModel = WardPtModel.fromSnapshot(await wardPtRef.doc(ptId).get());
        ptInitialised = true;
        return wardPtModel;
    //   }
    // } catch (e) {
    //   print(e.toString());
    //   error = true;
    // }
  }
}
