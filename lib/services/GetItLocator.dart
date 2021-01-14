import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'SocketIOService.dart';
import '../Providers/PaintProvider.dart';
import '../models/Point.dart';
import 'RouterService.dart';
import 'SocketStream.dart';
import 'DynamicLinkService.dart';
import 'HttpService.dart';
import 'LocalStorageService.dart';
import 'UserService.dart';
GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<SocketIOservice>(() => SocketIOservice());
  locator.registerLazySingleton<RouterService>(() => RouterService());
  locator.registerLazySingleton<SocketStream>(() => SocketStream());
  locator.registerLazySingleton<DynamicLinkService>(() => DynamicLinkService());
  locator.registerLazySingleton<HttpService>(() => HttpService());
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<UserService>(() => UserService());
  locator
      .registerFactoryParam<PaintProvider, List<Point>, Map<String, dynamic>>(
    (points, options) => PaintProvider(
      points,
      [],
      options["strokeWidth"],
      options["optionsIndex"],
      options["backgroundColor"],
      options["strokeColor"],
    ),
  );
}
