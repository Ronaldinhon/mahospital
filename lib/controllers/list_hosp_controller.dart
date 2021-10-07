import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/hosp_model.dart';

class HospListController extends GetxController {
  static HospListController instance = Get.find();

  List<HospModel> _hospModelList = [];

  List<HospModel> get hospModels => _hospModelList;

  HospModel hospModel(String hospId) =>
      _hospModelList.firstWhere((hm) => hm.id == hospId);

  bool hospIdInCont(String hospId) =>
      hospModels.map((hm) => hm.id).contains(hospId);

  void addHosp(HospModel value) => this._hospModelList.add(value);

  Future<HospModel> createAndReturn(String hospId) async {
    if (hospIdInCont(hospId))
      return hospModel(hospId);
    else {
      DocumentSnapshot<Object?> hosp = await hospRef.doc(hospId).get();
      var hospModel = HospModel.fromSnapshot(hosp);
      addHosp(hospModel);
      return hospModel;
    }
  }

  void clear() => _hospModelList = [];
}
