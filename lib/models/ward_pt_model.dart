import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:intl/intl.dart';

import 'hosp_model.dart';

class WardPtModel {
  late String id;
  late String initial;
  late String birthDate; //save as int ba
  late int genderIndex;
  late String gender;
  late String race;
  late String nickName;
  late String address;
  late List<String> rNos;
  late List<String> admittedAt;
  late List<String> dischargedAt;
  late String curDiag;
  late String curPlan;

  late List<String> activeDepts;
  late List<String> inactiveDepts;
  late String wardId;
  late String bedId;

  late String base16rmd;
  late String random32;
  late String name;
  late String icNumber;
  bool decoded = false;

  late String createdBy;
  late String idLastUpdatedBy;
  late String hospId;

  late Map entries;
  late Map latestEntry;
  late List<int> orderedDateTime;
  List<String> entryDataList = [];
  List<String> entryDeptList = [];
  List<String> uniqueDept = [];
  List<bool> isSel = [];

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
      id = snapshot.id;
      initial = snapshot.get('initial');
      name = snapshot.get('name');
      icNumber = snapshot.get('ic');
      birthDate = snapshot.get('dob');
      genderIndex = snapshot.get('gender');
      race = snapshot.get('race');
      nickName = snapshot.get('nickName');
      address = snapshot.get('address');
      List<dynamic> rns = snapshot.get('rn');
      rNos = rns.map((rn) => rn.toString().trim()).toList();
      List<dynamic> aAt = snapshot.get('admittedAt');
      admittedAt = aAt.map((rn) => rn.toString().trim()).toList();
      List<dynamic> dAt = snapshot.get('dischargedAt');
      dischargedAt = dAt.map((rn) => rn.toString().trim()).toList();
      hospId = snapshot.get('hospId');
      curDiag = snapshot.get('curDiag');
      curPlan = snapshot.get('curPlan');

// activeDepts
// inactiveDepts - no need
// if member of hosp then can see ba
      List<dynamic> aDepts = snapshot.get('deptIds');
      activeDepts = aDepts.map((rn) => rn.toString()).toList();
      wardId = snapshot.get('wardId') ?? '';
      base16rmd = snapshot.get('base16rmd');
      random32 = snapshot.get('random32');
      getEntries();
    } catch (e) {
      Get.snackbar("Error retrieving patient data",
          e.toString() + ' Please refresh ward page.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5));
    }
  }

  String rnNos() {
    return rNos.join(', ');
  }

  String aAts() {
    return admittedAt.join(', ');
  }

  String dAts() {
    return dischargedAt.join(', ');
  }

  String ptDetails() {
    int age = DateTime.now()
            .difference(DateFormat('dd/MM/yyyy').parse(birthDate))
            .inDays ~/
        365;

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
    return '${name.capitalize}, ${age}yo ${race.capitalize} $gender';
  }

  String age() {
    String ageWithUnit = '';
    int ageInDays = DateTime.now()
        .difference(DateFormat('dd/MM/yyyy').parse(birthDate))
        .inDays;
    int agee = ageInDays ~/ 365;
    if (agee >= 1) {
      ageWithUnit = agee.toString() + 'yo';
    } else {
      agee = ageInDays ~/ 30;
      ageWithUnit = agee.toString() + ' months';
    }
    if (agee == 0) ageWithUnit = ageInDays.toString() + ' days';
    return ageWithUnit;
  }

  // void setQrCred(String name, String iC) {
  //   name = name;
  //   icNumber = iC;
  // }

  Future<void> getEntries() async {
    DocumentSnapshot entrySS =
        await wardPtRef.doc(id).collection('entries').doc('1').get();
    if (entrySS.exists) {
      rerIni = true;
      entries = entrySS.get('entries');
      orderedDateTime = entries.keys.map((f) => int.parse(f)).toList();
      orderedDateTime.sort((a, b) => b.compareTo(a));
      orderedDateTime.forEach((itt) {
        entryDataList.add(entries[itt.toString()]['data'].toString());
        entryDeptList.add(entries[itt.toString()]['dept'].toString());
        uniqueDept.add(entries[itt.toString()]['dept'].toString());
      });
      print(name + orderedDateTime.length.toString());
      uniqueDept = uniqueDept.toSet().toList();
      // print(uniqueDept);
      uniqueDept.forEach((i) => isSel.add(false));
      latestEntry = entries[orderedDateTime.first.toString()];
      // print(latestEntry['data'].toString());
    }
  }

  void addFakeEntry() {
    var wusc = DateTime.now().millisecondsSinceEpoch;
    var dup = entries[orderedDateTime.last.toString()];
    entryDataList.add(dup['data'].toString());
    entryDeptList.add(dup['dept'].toString());
    uniqueDept.add(dup['dept'].toString());
    uniqueDept = uniqueDept.toSet().toList();
    orderedDateTime.add(wusc);
    entries[wusc.toString()] = dup;
  }
}
