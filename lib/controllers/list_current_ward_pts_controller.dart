// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mahospital/constants/firebase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
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

  TextEditingController dnameCont = TextEditingController(text: '');
  TextEditingController drnCont = TextEditingController(text: '');
  TextEditingController dicCont = TextEditingController(text: '');
  TextEditingController dageCont = TextEditingController(text: '');
  TextEditingController ddobCont = TextEditingController(text: '');
  TextEditingController daddCont = TextEditingController(text: '');
  TextEditingController dsexCont = TextEditingController(text: '');
  TextEditingController ddoaCont = TextEditingController(text: '');
  TextEditingController ddodCont = TextEditingController(text: '');
  TextEditingController dwardCont = TextEditingController(text: '');
  TextEditingController dfdxCont = TextEditingController(text: '');
  TextEditingController dfupCont = TextEditingController(text: '');
  TextEditingController dnoteCont = TextEditingController(text: '');


  late pw.PageTheme theme;

  Future<void> setPdfTheme() async {
    theme = await _myPageTheme();
  }

  Future<pw.PageTheme> _myPageTheme() async {
    PdfPageFormat format = pf.PdfPageFormat.a4;
    format.applyMargin(
        left: 1.0 * PdfPageFormat.cm,
        top: 3.0 * PdfPageFormat.cm,
        right: 1.0 * PdfPageFormat.cm,
        bottom: 1.0 * PdfPageFormat.cm);
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
        ecController.entryData = [];
        ecController.depts = [];
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
        ecController.entryData = [];
        ecController.depts = [];
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
