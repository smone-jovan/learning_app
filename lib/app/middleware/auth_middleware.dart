import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/app/routes/app_routes.dart';
import 'package:learning_app/presentation/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      // Get AuthController
      final authController = Get.find<AuthController>();

      // ✅ FIX: currentUser is already User? type, no need .value
      // Check if user is authenticated
      if (authController.currentUser == null) {
        // User not authenticated, redirect to login
        return const RouteSettings(name: AppRoutes.LOGIN);
      }

      // User authenticated, allow access
      return null;
    } catch (e) {
      // Error occurred, redirect to login for safety
      print('Auth middleware error: $e');
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
  }
}
