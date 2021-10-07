import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/ward_pt_model.dart';

class CurrentWardPtsListController extends GetxController {
  static CurrentWardPtsListController instance = Get.find();

  late int currentIndex;
  late List<WardPtModel> _currentWardPtsModelList;
  Rx<WardPtModel> cwpm = WardPtModel().obs;

  List<WardPtModel> get currentWardPtModels => _currentWardPtsModelList;

  void setCurrentPtsList(List<WardPtModel> wpml) => //first
      _currentWardPtsModelList = wpml;

  void setCurrentIndex(int i) {
    //then only this
    currentIndex = i;
    cwpm.value = currentWardPtModel();
  }

  WardPtModel currentWardPtModel() => currentWardPtModels[currentIndex];

  void clear() => _currentWardPtsModelList = [];

  void increment() {
    if (currentIndex < currentWardPtModels.length)
      setCurrentIndex(++currentIndex);
  }

  void decrement() {
    if (currentIndex > 0) setCurrentIndex(--currentIndex);
  }
}
