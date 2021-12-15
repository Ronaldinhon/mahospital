import 'package:mahospital/controllers/entry_chart_controller.dart';
import 'package:mahospital/controllers/list_all_ward_pts_controller.dart';
import 'package:mahospital/controllers/list_current_ward_pts_controller.dart';
import 'package:mahospital/controllers/sum_rer_controller.dart';
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
AllWardPtListController allWardPtListController =
    AllWardPtListController.instance;
CurrentWardPtsListController currentWPLC =
    CurrentWardPtsListController.instance;
EntryChartController ecController = EntryChartController.instance;
// SumRerController sumRC = SumRerController.instance;

// do i need to add authController and userController ?
