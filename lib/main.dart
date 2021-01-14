import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/Home.dart';
import 'services/GetItLocator.dart';
import 'services/RouterService.dart';
import 'services/DynamicLinkService.dart';
import 'screens/IntroductionScreen.dart';
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  Firebase.initializeApp();
  await setupLocator();
  final DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  RouterService _routerService = locator<RouterService>();
  await _dynamicLinkService.handleDynamicLinks();

  runApp(MaterialApp(
    home: IntroductionScreen(),
    debugShowCheckedModeBanner: false,
    onGenerateRoute: _routerService.generateRoutes,
    navigatorKey: _routerService.navigationKey,
  ));
}