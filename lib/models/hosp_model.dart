import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';

class HospModel {
  late String id;
  late String name;
  late String shortName;
  late String imageUrl;
  late String ownerId;
  late bool verified;

  HospModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      // print(snapshot.toString());
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      imageUrl = snapshot.get('imageUrl');
      ownerId = snapshot.get('ownerId');
      verified = snapshot.get('verified');
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

  void getHospMemberModels(String hospId) {

  }
}
