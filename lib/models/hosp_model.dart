import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/user.dart';

class HospModel {
  late String id;
  late String name;
  late String shortName;
  late String imageUrl;
  late String ownerId;
  late String address;
  late bool verified;
  late List<dynamic> members;
  late List<UserModel> memberModels;
  late List<DeptModel> deptModels;

  HospModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      imageUrl = snapshot.get('imageUrl');
      ownerId = snapshot.get('ownerId');
      address = snapshot.get('address');
      verified = snapshot.get('verified');
      members = snapshot.get('members');
      id = snapshot.id;
      // initialized = true;
    } catch (e) {
      Get.snackbar(
        "Error retrieving hospital data",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  // call from hosp screen
  Future<List<DeptModel>> getDeptList() async {
    List<DeptModel> emptyToFull = [];
    QuerySnapshot<Object?> deptObjs =
        await deptRef.where('hospId', isEqualTo: id).get();
    deptObjs.docs.forEach(
        (v) => emptyToFull.add(DeptModel.fromSnapshot(v, guaw: false)));
    deptModels = emptyToFull;
    print(deptModels.length);
    return deptModels;
  }

  void getHospMemberModels(String hospId) {
    memberModels = userListController.createAndReturnForDept(members);
  }

  String getName() {
    return "$name - $shortName";
  }
}
