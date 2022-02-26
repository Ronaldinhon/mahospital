import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';

import 'hosp_model.dart';

class DeptModel {
  late String id;
  late String name;
  late String shortName;
  late String hospId;
  late String hospName;
  late String hospShortName;
  late String imageUrl;
  late String ownerId;
  late List<dynamic> members;
  late List<UserModel> memberModels;
  late List<WardModel> wardModels;
  late HospModel hospModel;
  late bool verified;
  bool membersInitialised = false;
  bool wardsInitialised = false;
  List<String> wardIdList = [];
  List<WardPtModel> lpwpm = []; // list of peri wardPtModel

  // static Future<DeptModel> create(snapshot) async {
  //   return DeptModel.fromSnapshot(snapshot);
  // }
  DeptModel(this.id, this.name);
  // did not work

  DeptModel.fromSnapshot(DocumentSnapshot snapshot, {bool guaw: true}) {
    //get user and ward
    try {
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      hospId = snapshot.get('hospId');
      imageUrl = snapshot.get('imageUrl');
      ownerId = snapshot.get('ownerId');
      verified = snapshot.get('verified');
      members = snapshot.get('members');
      hospShortName = snapshot.get('hospShortName');
      id = snapshot.id;
      // getHospName(hospId);
      // if (guaw) {
      //   getUserModels();
      //   getWards();
      // }
      // initialized = true;
    } catch (e) {
      Get.snackbar(
        "Error retrieving department data",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void getHospName(String hospId) async {
    hospModel = await hospListController.createAndReturn(hospId);
    hospName = hospModel.name;
    hospShortName = hospModel.shortName;
  }

  Future<List<UserModel>> getUserModels() async {
    //called only when in dept screen
    if (membersInitialised)
      return memberModels;
    else {
      memberModels = await userListController.createAndReturnForDept(members);
      membersInitialised = true;
      return memberModels;
    }
  }

  Future<List<WardModel>> getWards() async {
    //called only when in dept screen
    if (wardsInitialised)
      return wardModels;
    else {
      List<WardModel> emptyToFull = [];
      QuerySnapshot<Object?> wardObjs =
          await wardRef.where('deptId', isEqualTo: id).get();

      for (var wo in wardObjs.docs) {
        emptyToFull.add(WardModel.fromSnapshot(wo));
        wardIdList.add(wo.id);
      }
      
      // You cannot use 'array_contains' filters with 'not_in' filters.
      // await wardPtRef
      //     .where('wardId', whereNotIn: wardIdList)
      //     .where('deptIds', arrayContains: id)
      //     .get()
      //     .then((qss) {
      //   print(qss);
      //   for (var d in qss.docs) {
      //     var wpm = WardPtModel.fromSnapshot(d);
      //     lpwpm.add(wpm);
      //   }
      // });
      wardModels = emptyToFull;
      return wardModels;
    }
  }
}
