import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
// import 'package:mahospital/routing/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  redirect(String? route) =>
      authController.user == null ? RouteSettings(name: '/login') : null;
}

// class VerifiedMiddleware extends GetMiddleware {
//   @override
//   redirect(String? route) => userController.user.verified
//       ? RouteSettings(name: profilePageRoute)
//       : null;
// }
