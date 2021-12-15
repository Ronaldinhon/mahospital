// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mahospital/constants/firebase.dart';
import 'package:get/get.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';

class CurrentWardPtsListController extends GetxController {
  static CurrentWardPtsListController instance = Get.find();

  int currentIndex = 0; //set initial as 0 when there is no pt
  List<WardPtModel> _currentWardPtsModelList = [];
  Rx<WardPtModel> cwpm = WardPtModel().obs;
  Rx<BedModel> cbm = BedModel().obs;
  List<BedModel> currentBML = []; //currentBedModelList

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
