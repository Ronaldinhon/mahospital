// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mahospital/constants/firebase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/src/pdf/page_format.dart' as pf;

class CurrentWardPtsListController extends GetxController {
  static CurrentWardPtsListController instance = Get.find();

  int currentIndex = 0; //set initial as 0 when there is no pt
  List<WardPtModel> _currentWardPtsModelList = [];
  Rx<WardModel> cwm = WardModel().obs;
  Rx<WardPtModel> cwpm = WardPtModel().obs;
  Rx<BedModel> cbm = BedModel().obs;
  Rx aptb = false.obs; //addmitingPtToBed
  List<BedModel> currentBML = []; //currentBedModelList
  TextEditingController yeah = TextEditingController(text: '');
  TextEditingController dateCont = TextEditingController(text: '');
  TextEditingController timeCont = TextEditingController(text: '');

  TextEditingController dnoteCont = TextEditingController(text: '');

  TextEditingController cpName = TextEditingController(text: '');
  TextEditingController cpIc = TextEditingController(text: '');
  TextEditingController cpDOB = TextEditingController(text: '');
  TextEditingController cpRace = TextEditingController(text: '');
  TextEditingController cpRNnos = TextEditingController(text: '');
  TextEditingController cpAdd = TextEditingController(text: '');
  TextEditingController cpaAts = TextEditingController(text: '');
  TextEditingController cpdAts = TextEditingController(text: '');
  TextEditingController cpCurDiag = TextEditingController(text: '');
  TextEditingController cpCurPlan = TextEditingController(text: '');
  Rx updatingPt = false.obs;
  Rx updatingPtSum = false.obs;
  List<bool> isSelected = [true, false, false];

  late pw.PageTheme theme;

  Map<String, dynamic> initialMap = {};

  Future<void> savePtSum() async {
    updatingPtSum.value = true;
    await wardPtRef.doc(cwpm.value.id).update({
      'curDiag': cpCurDiag.text,
      'curPlan': cpCurPlan.text,
      'lastUpdatedBy': auth.currentUser!.uid,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      updateCurrentWPM();
      Get.snackbar("Success", 'Updated patient summary',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2));
    }).catchError((e) {
      print(e);
      Get.snackbar("Error Updating patient summary", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2));
    });
    updatingPtSum.value = false;
  }

  Future<void> updatePtDetails() async {
    updatingPt.value = true;
    await wardPtRef.doc(cwpm.value.id).update({
      'name': cpName.text,
      'ic': cpIc.text,
      'dob': cpDOB.text,
      'race': cpRace.text,
      'rn': cpRNnos.text.split(',').map((rn) => rn.trim()).toList(),
      'address': cpAdd.text,
      'gender': isSelected.indexWhere((g) => g),
      'lastUpdatedBy': auth.currentUser!.uid,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      updateCurrentWPM();
      Get.snackbar("Success", 'Updated patient data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2));
    }).catchError((e) {
      print(e);
      Get.snackbar("Error Updating patient data", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2));
    });
    updatingPt.value = false;
  }

  void updatePtDetailsConts(WardPtModel model) {
    isSelected = [false, false, false];
    isSelected[model.genderIndex] = true;
    cpName.text = model.name;
    cpIc.text = model.icNumber;
    cpDOB.text = model.birthDate;
    cpRace.text = model.race;
    cpRNnos.text = model.rnNos();
    cpaAts.text = model.aAts();
    cpdAts.text = model.dAts();
    cpCurDiag.text = model.curDiag;
    cpCurPlan.text = model.curPlan;
    cpAdd.text = model.address;
    ecController.start.value = model.entries.keys.length;
    ecController.end.value = model.entries.keys.length;
    // ecController.entries = model.entries; // how to update when new entry is added
  }

  void updateCurrentWPM() {
    WardPtModel temporr = cwpm.value;
    temporr.name = cpName.text;
    temporr.icNumber = cpIc.text;
    temporr.birthDate = cpDOB.text;
    temporr.race = cpRace.text;
    temporr.rNos = cpRNnos.text.split(',').map((rn) => rn.trim()).toList();
    temporr.genderIndex = isSelected.indexWhere((g) => g);
    temporr.curDiag = cpCurDiag.text;
    temporr.curPlan = cpCurPlan.text;
    temporr.address = cpAdd.text;
    cwpm.value = temporr;
    var index = _currentWardPtsModelList.indexWhere((wpm) {
      return temporr.id == wpm.id;
    });
    _currentWardPtsModelList.replaceRange(index, index + 1, [temporr]);
  }

  void discDept(String deptId) {
    WardPtModel temporr = cwpm.value;
    temporr.activeDepts.remove(deptId);
    var index = _currentWardPtsModelList.indexWhere((wpm) {
      return temporr.id == wpm.id;
    });
    cwpm.value = temporr;
    _currentWardPtsModelList.replaceRange(index, index + 1, [temporr]);
  }

  Future<void> setPdfTheme() async {
    theme = await _myPageTheme();
  }

  Future<pw.PageTheme> _myPageTheme() async {
    PdfPageFormat format = pf.PdfPageFormat.a4;
    format.applyMargin(
        left: 0 * PdfPageFormat.cm,
        top: 0 * PdfPageFormat.cm,
        right: 0 * PdfPageFormat.cm,
        bottom: 0 * PdfPageFormat.cm);
    return pw.PageTheme(
      pageFormat: format,
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.averiaSerifLibreRegular(),
        bold: await PdfGoogleFonts.averiaSerifLibreBold(),
        icons: await PdfGoogleFonts.materialIcons(),
      ),
    );
  }

  List<WardPtModel> get currentWardPtModels => _currentWardPtsModelList;

  void setCurrentPtsList(List<WardPtModel> wpml) => //first
      _currentWardPtsModelList = wpml;

  void setCurrentIndex(int i) {
    currentIndex = i;
    cwpm.value = currentWardPtModel();
  }

  void setCurrentIndexByPtId(String ptId) {
    // add 1 to current index, easier to add pt later - cannot will affect currentWardPtModel
    int index = currentWardPtModels.indexWhere((wpm) => wpm.id == ptId);
    currentIndex = index;
    cwpm.value = currentWardPtModel();
  }

  void addPtModel(WardPtModel wpm) {
    _currentWardPtsModelList.insert(++currentIndex, wpm); // here got problem
    // need to reset index?? - need
    setCurrentIndex(++currentIndex);
  }

  WardPtModel currentWardPtModel() => currentWardPtModels[currentIndex];

  void clear() => _currentWardPtsModelList = [];

  void increment() {
    // if (currentIndex < currentWardPtModels.length)
    //   setCurrentIndex(++currentIndex);
    for (var i = findCurrentBed() + 1; i < currentBML.length; i++) {
      if (currentBML[i].ptInitialised) {
        cbm.value = currentBML[i];
        cwpm.value = currentBML[i].wardPtModel;
        // ecController.entryData = [];
        // ecController.depts = [];
        updatePtDetailsConts(cwpm.value);
        break;
      }
    }
  }

  void decrement() {
    // if (currentIndex > 0) setCurrentIndex(--currentIndex);
    for (var i = findCurrentBed() - 1; i >= 0; i--) {
      if (currentBML[i].ptInitialised) {
        cbm.value = currentBML[i];
        cwpm.value = currentBML[i].wardPtModel;
        // ecController.entryData = [];
        // ecController.depts = [];
        updatePtDetailsConts(cwpm.value);
        break;
      }
    }
  }

  void setBML(List<BedModel> bedModels) {
    currentBML = bedModels;
  }

  int findCurrentBed() {
    // BedModel cbm = currentBML
    //     .where((bm) => bm.ptInitialised)
    //     .firstWhere((bm) => bm.ptId == cwpm.value.id);
    // return currentBML.indexWhere((bm) => bm.id == cbm.id);
    return currentBML
        .indexWhere((bm) => bm.ptId == cwpm.value.id); // should work ba
  }
}
