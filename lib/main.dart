import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/data/services/firebase_service.dart';
import 'app/data/services/local_storage_services.dart';
import 'core/theme/app_theme.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
// Initialize Firebase
await FirebaseService.initialize();
// Initialize Local Storage
await LocalStorageService.init();
runApp(const MyApp());
}
class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return GetMaterialApp(
title: 'Learning App',
debugShowCheckedModeBanner: false,
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.system,
initialRoute: AppRoutes.SPLASH,
getPages: AppPages.pages,
);
}
}