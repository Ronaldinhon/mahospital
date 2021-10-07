import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  redirect(String? route) =>
      authController.user == null ? RouteSettings(name: '/login') : null;
}
