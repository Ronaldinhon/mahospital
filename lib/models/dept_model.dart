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

  DeptModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      // print(snapshot.toString());
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      hospId = snapshot.get('hospId');
      imageUrl = snapshot.get('imageUrl');
      ownerId = snapshot.get('ownerId');
      verified = snapshot.get('verified');
      members = snapshot.get('members');
      id = snapshot.id;
      getHospName(hospId);
      getUserModels();
      getWards(id);
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

  void getUserModels() async {
    memberModels = userListController.createAndReturnForDept(members);
  }

  void getWards(String deptId) async {
    List<WardModel> emptyToFull = [];
    QuerySnapshot<Object?> wardObjs =
        await wardRef.where('deptId', isEqualTo: deptId).get();
    wardObjs.docs.forEach((wo) => emptyToFull.add(WardModel.fromSnapshot(wo)));
    wardModels = emptyToFull;
  }
}
