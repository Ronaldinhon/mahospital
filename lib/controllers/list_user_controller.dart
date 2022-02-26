import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/user.dart';

class UserListController extends GetxController {
  static UserListController instance = Get.find();

  List<UserModel> _userModelList = [];

  List<UserModel> get userModels => _userModelList;

  UserModel userModel(String userId) =>
      _userModelList.firstWhere((um) => um.id == userId);

  bool userIdInCont(String hospId) => //copy from hospListModel
      userModels.map((hm) => hm.id).contains(hospId);

  void addUser(UserModel value) => this._userModelList.add(value);

  String userSName(String userId) =>
      _userModelList.firstWhere((um) => um.id == userId).shortName;

  Future<List<UserModel>> createAndReturnForDept(List userIds) async {
    List<UserModel> emptyToFull = [];
    // userIds.forEach((ui) async {
    for (var ui in userIds) {
      if (userIdInCont(ui))
        emptyToFull.add(userModel(ui));
      else {
        DocumentSnapshot<Object?> uo = await userRef.doc(ui).get();
        var hospModel = UserModel.fromSnapshot(uo);
        addUser(hospModel);
        emptyToFull.add(hospModel);
      }
    }
    // );
    return emptyToFull;
  }

  Future<void> createAndSave(String hospId) async {
    if (!userIdInCont(hospId)) {
      DocumentSnapshot<Object?> hosp = await userRef.doc(hospId).get();
      UserModel userModel = UserModel.fromSnapshot(hosp);
      addUser(userModel);
    }
    // return userModel;
  }

  void clear() => _userModelList = [];
}
