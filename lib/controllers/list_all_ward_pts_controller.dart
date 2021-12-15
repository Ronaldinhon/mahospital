import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/ward_pt_model.dart';

class AllWardPtListController extends GetxController {
  static AllWardPtListController instance = Get.find();

  List<WardPtModel> _wardPtModelList = [];

  List<WardPtModel> get wardPtModels => _wardPtModelList;

  WardPtModel wardPtModel(String hospId) =>
      _wardPtModelList.firstWhere((hm) => hm.id == hospId);

  bool ptIdInCont(String hospId) => //copy from hospListModel
      wardPtModels.map((hm) => hm.id).contains(hospId);

  void addWardPt(WardPtModel value) => this._wardPtModelList.add(value);

  Future<WardPtModel> createAndReturn(String hospId) async {
    print('it came here');
    if (ptIdInCont(hospId))
      return wardPtModel(hospId);
    else {
      DocumentSnapshot<Object?> hosp = await wardPtRef.doc(hospId).get();
      var hospModel = WardPtModel.fromSnapshot(hosp);
      print(hospModel);
      addWardPt(hospModel);
      return hospModel;
    }
  }

  void clear() => _wardPtModelList = [];
}
