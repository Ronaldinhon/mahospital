import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/hosp_model.dart';

class HospListController extends GetxController {
  bool listAllHospDone = false;

  static HospListController instance = Get.find();

  List<HospModel> _hospModelList = [];

  List<HospModel> get hospModels => _hospModelList;

  HospModel hospModel(String hospId) =>
      _hospModelList.firstWhere((hm) => hm.id == hospId);

  bool hospIdInCont(String hospId) =>
      hospModels.map((hm) => hm.id).toList().contains(hospId);

  void addHosp(HospModel value) => this._hospModelList.add(value);

  Future<HospModel> createAndReturn(String hospId) async {
    if (hospIdInCont(hospId))
      return hospModel(hospId);
    else {
      DocumentSnapshot<Object?> hosp = await hospRef.doc(hospId).get();
      HospModel hospModel = HospModel.fromSnapshot(hosp);
      addHosp(hospModel);
      return hospModel;
    }
  }

  Future<HospModel> refreshHospModel(String hospId) async {
    DocumentSnapshot<Object?> hospSS = await hospRef.doc(hospId).get();
    HospModel hnm = HospModel.fromSnapshot(hospSS);
    hospModels.removeWhere((hModel) => hModel.id == hospId);
    addHosp(hnm);
    return hnm;
  }

  // need to write function to add hospId into approved list
  Future<List<HospModel>> getAllHosp() async {
    if (listAllHospDone)
      return hospModels;
    else {
      // DocumentSnapshot<Object?> approvedHospIds = await appHospRef.doc('1').get();
      // List<dynamic> ahi = approvedHospIds.get('ids');
      // ahi.forEach((hId) => createAndReturn(hId));

      // duplicates noted in web only - actually on android app also...
      // reason for duplicate - we get hosp model from dept 
      // (web not fast enough to initiate hosplistcontroller) in createAndReturn
      // List<HospModel> hospTsk = []; 
      QuerySnapshot<Object?> allHosp = await hospRef.get();
      allHosp.docs.forEach((doc) {
        createAndReturn(doc.id);
        // hospTsk.add(HospModel.fromSnapshot(doc));
      });

      // listAllHospDone = true;
      // if (kIsWeb) return hospTsk;
      return hospModels.toSet().toList();
    }
  }

  void clear() => _hospModelList = [];
}
