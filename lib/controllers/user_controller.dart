import 'package:get/get.dart';
import 'package:mahospital/models/user.dart';

class UserController extends GetxController {
  static UserController instance = Get.find();

  Rx<UserModel> _userModel = UserModel().obs;

  UserModel get user => _userModel.value;

  void setUser(UserModel value) => this._userModel.value = value;

  void clear() {
    _userModel.value = UserModel();
  }
}