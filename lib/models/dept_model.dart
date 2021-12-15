import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/models/ward_model.dart';

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
      id = snapshot.id;
      getHospName(hospId);
      if (guaw) {
        getUserModels();
        getWards();
      }
      // getUserModel
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
    if (membersInitialised)
      return memberModels;
    else {
      memberModels = userListController.createAndReturnForDept(members);
      membersInitialised = true;
      return memberModels;
    }
  }

  Future<List<WardModel>> getWards() async {
    if (wardsInitialised)
      return wardModels;
    else {
      List<WardModel> emptyToFull = [];
      QuerySnapshot<Object?> wardObjs =
          await wardRef.where('deptId', isEqualTo: id).get();
      wardObjs.docs
          .forEach((wo) => emptyToFull.add(WardModel.fromSnapshot(wo)));
      wardModels = emptyToFull;
      return wardModels;
    }
  }
}
