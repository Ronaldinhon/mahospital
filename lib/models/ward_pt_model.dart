import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

import 'hosp_model.dart';

class WardPtModel {
  late String id;
  late String initial;
  late int birthDate; //save as int ba
  late int genderIndex;
  late String race;
  late List<String> rNos;

  late List<String> activeDepts;
  late List<String> inactiveDepts;
  late String wardId;
  late String bedId;

  late String base16rmd;
  late String random32;
  late String fullName;
  late String icNumber;
  bool decoded = false;

  late String createdBy;
  late String idLastUpdatedBy;
  late String hospId;

  // bool individualFieldInitialised = false;
  bool sumIni = false;
  bool rerIni = false;
  bool vsIni = false;
  bool tempIni = false;
  bool fcIni = false;
  bool ecgIni = false;
  bool ccIni = false;
  bool imageIni = false;
  bool drugIni = false;
  bool ioIni = false;

  WardPtModel();

  WardPtModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      
    } catch (e) {
      Get.snackbar(
        "Error retrieving patient data",
        e.toString() + ' Please refresh ward page.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5)
      );
    }
  }

  String ptDetails() {
    int age = DateTime.now()
            .difference(DateTime.fromMicrosecondsSinceEpoch(birthDate))
            .inDays ~/
        365;
    String gender;
    switch (genderIndex) {
      case 0:
        gender = 'Male';
        break;
      case 1:
        gender = 'Female';
        break;
      default:
        gender = 'Agender';
    }
    return '$initial, ${age}yo $race $gender';
  }
}
