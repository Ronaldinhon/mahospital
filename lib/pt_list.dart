import 'dart:io';

import 'package:flutter/foundation.dart';

class PtList with ChangeNotifier {
  late List<dynamic> ptList;
  late int currentIndex;

  String get currentPtId {
    return ptList[currentIndex];
  }

  // set setCurrentIndex(int i) {
  //   currentIndex = i;
  // }

  void setCurrentIndex(int i) {
    currentIndex = i;
  }

  void setList(List<dynamic> i) {
    ptList = i;
  }

  void increment() {
    if (currentIndex < ptList.length) currentIndex++;
    notifyListeners();
  }

  void decrement() {
    if (currentIndex > 0) currentIndex--;
    notifyListeners();
  }
}
