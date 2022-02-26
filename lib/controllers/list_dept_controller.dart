import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';

class DeptListController extends GetxController {
  // bool listAllHospDone = false;

  static DeptListController instance = Get.find();

  List<DeptModel> _deptModelList = [];

  List<String> hospIdDone = [];

  List<DeptModel> get deptModels => _deptModelList;

  DeptModel deptModel(String deptId) =>
      _deptModelList.firstWhere((hm) => hm.id == deptId);

  bool deptIdInCont(String deptId) =>
      deptModels.map((hm) => hm.id).toList().contains(deptId);

  String deptName(String deptId) {
    return _deptModelList.firstWhere((hm) => hm.id == deptId).name;
  }

  String deptSName(String deptId) {
    return _deptModelList.firstWhere((hm) => hm.id == deptId).shortName;
  }

  List<DeptModel> currentHospDepts(String hospId) =>
      _deptModelList.where((dm) => dm.hospId == hospId).toList();

  void addDept(DeptModel value) => this._deptModelList.add(value);

  void addDepts(List<DeptModel> diss) {
    _deptModelList.addAll(diss);
  }

  Future<DeptModel> createAndReturn(
      QueryDocumentSnapshot<Object?> deptSS) async {
    print(deptIdInCont(deptSS.id)); // added this line and it worked
    if (deptIdInCont(deptSS.id)) {
      return deptModel(deptSS.id);
    } else {
      // DocumentSnapshot<Object?> hosp = await deptRef.doc(deptSS).get();
      DeptModel deptModel = DeptModel.fromSnapshot(deptSS);
      addDept(deptModel);
      return deptModel;
    }
  }

  Future<DeptModel> refreshDeptModel(String deptId) async {
    DocumentSnapshot<Object?> hospSS = await hospRef.doc(deptId).get();
    DeptModel hnm = DeptModel.fromSnapshot(hospSS);
    deptModels.removeWhere((hModel) => hModel.id == deptId);
    addDept(hnm);
    return hnm;
  }

  Future<void> getDeptsOfHosp(String hospId) async {
    if (!hospIdDone.contains(hospId)) {
      QuerySnapshot<Object?> allDept =
          await deptRef.where('hospId', isEqualTo: hospId).get();
      for (var doc in allDept.docs) {
        await createAndReturn(doc);
      }
      hospIdDone.add(hospId);
    }
  }

  void clear() => _deptModelList = [];
}
