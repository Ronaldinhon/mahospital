import 'package:mahospital/controllers/list_all_ward_pt.dart';
import 'package:mahospital/controllers/list_current_ward_pts_controller.dart';
import 'package:mahospital/controllers/user_controller.dart';
import 'package:mahospital/controllers/list_hosp_controller.dart';
import 'package:mahospital/controllers/list_user_controller.dart';

import '../controllers/auth_controller.dart';

// import '../controllers/menu_controller.dart';
// import '../controllers/navigation_controller.dart';

// MenuController menuController = MenuController.instance;
// NavigationController navigationController = NavigationController.instance;
AuthController authController = AuthController.instance;
UserController userController = UserController.instance;

HospListController hospListController = HospListController.instance;
UserListController userListController = UserListController.instance;
AllWardPtListController allWardPtListController = AllWardPtListController.instance;
CurrentWardPtsListController currentWardPtsListController = CurrentWardPtsListController.instance;

// do i need to add authController and userController ?