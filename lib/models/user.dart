import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

import 'dept_model.dart';

class UserModel {
  late String id;
  late String name;
  late String shortName;
  late String email;
  late String imageUrl;
  late String title;
  late int reg;
  late bool verified;
  late String verifiedBy;
  late List<DeptModel> userDepts;
  late String createPlatform;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool deptInitialised = false;

  UserModel();

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      email = snapshot.get('email');
      imageUrl = snapshot.get('imageUrl');
      title = snapshot.get('title');
      reg = snapshot.get('reg');
      verified = snapshot.get('verified');
      verifiedBy = snapshot.get('verifiedBy') ?? '';
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      id = snapshot.id;
      // deptList();
      // initialized = true;
    } catch (e) {
      Get.snackbar(
        "Error retrieving user data",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<List> deptList() async {
    if (deptInitialised)
      return userDepts;
    else {
      List<DeptModel> emptyToFull = [];
      QuerySnapshot<Object?> deptObjs =
          await deptRef.where('members', arrayContainsAny: [id]).get();
      // deptObjs.docs.forEach((v) => emptyToFull.add(DeptModel.fromSnapshot(v)));
      for (var v in deptObjs.docs) {
        emptyToFull.add(DeptModel.fromSnapshot(v));
        // emptyToFull.add(await DeptModel.create(v)); 
        // above didnt work either
        // resulted to having hospShortName in dept model
      }
      userDepts = emptyToFull;
      deptInitialised = true;
      deptListController.addDepts(emptyToFull);
      return emptyToFull;
    }
  }

  Future<bool> veri() async {
    return verified;
  }
}
