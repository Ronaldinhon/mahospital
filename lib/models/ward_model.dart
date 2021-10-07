import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/controllers/list_all_ward_pt.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';

class WardModel {
  late String id;
  late String name;
  late String shortName;
  late String description;
  late String deptId;
  late String hospId;
  late String imageUrl;
  late String ownerId;
  late List<dynamic> bedIdList;
  late List<dynamic> patients;
  late List<dynamic> pendingPts; // not yet use
  late List<BedModel> bedModels;
  late List<WardPtModel> patientModels;
  bool bedInitialized = false;
  bool ptInitialized = false;

  WardModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      description = snapshot.get('description');
      deptId = snapshot.get('deptId');
      hospId = snapshot.get('hospId');
      imageUrl = snapshot.get('imageUrl');
      ownerId = snapshot.get('ownerId');
      bedIdList = snapshot.get('bedIdList');
      patients = snapshot.get('noBedPts');
      id = snapshot.id;
      // getBeds(hospId);
    } catch (e) {
      Get.snackbar(
        "Error retrieving ward data",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  // both getbeds and getpts needs future
  Future<List<BedModel>> getBeds() async {
    if (bedInitialized)
      return bedModels;
    else {
      List<BedModel> emptyToFull = [];
      QuerySnapshot<Object?> bedObjs =
          await bedRef.where('wardId', isEqualTo: id).get();
      List<QueryDocumentSnapshot<Object?>> bedObjDocs = bedObjs.docs;
      bedIdList.forEach((bi) {
        emptyToFull.add(BedModel.fromSnapshot(
            bedObjDocs.firstWhere((bod) => bod.id == bi)));
      });
      // bedObjs.docs.forEach((bo) {
      //   emptyToFull.add(BedModel.fromSnapshot(bo));
      // });
      print(emptyToFull.length);
      bedModels = emptyToFull;
      bedInitialized = true;
      return emptyToFull;
    }
  }

  Future<List<WardPtModel>> getPts() async {
    if (ptInitialized)
      return patientModels;
    else {
      List<WardPtModel> emptyToFull = [];
      QuerySnapshot<Object?> ptObjs = await wardPtRef
          .where('pendingTOto', isEqualTo: id)
          // .where('wardId', isEqualTo: id)
          // .where('bedId', isNull: true)
          .get();
      if (ptObjs.docs.length != 0)
        ptObjs.docs.forEach((po) async {
          emptyToFull.add(await allWardPtListController.createAndReturn(
              po.id)); // not optimised but should be not too many
        });
      patientModels = emptyToFull;
      ptInitialized = true;
      return emptyToFull;
    }
  }
}
