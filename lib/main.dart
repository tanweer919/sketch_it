import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/User.dart';
import 'services/GetItLocator.dart';
import 'services/RouterService.dart';
import 'services/DynamicLinkService.dart';
import 'Start.dart';
import 'services/UserService.dart';
import 'Providers/AppProvider.dart';
import 'services/SocketIOService.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  //Theme for the app
  final ThemeData theme = ThemeData(
      primaryColor: Color(0xfffad149),
      accentColor: Color(0xff4eaa51),
      primaryColorDark: Color(0X8A000000),
      fontFamily: 'IBMPlexSans');
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  Firebase.initializeApp();
  await setupLocator();
  UserService _userService = locator<UserService>();
  final User currentUser = await _userService.fetchCurrentUser();
  final AppProvider _appProvider = locator<AppProvider>(param1: currentUser);
  final DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  final SocketIOService _socketIOService = locator<SocketIOService>();
  RouterService _routerService = locator<RouterService>();
  await _dynamicLinkService.handleDynamicLinks();
  _socketIOService.connectToServer();

  runApp(ChangeNotifierProvider(
    create: (context) => _appProvider,
    child: MaterialApp(
      home: Start(),
      theme: theme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _routerService.generateRoutes,
      navigatorKey: _routerService.navigationKey,
    ),
  ));
}
