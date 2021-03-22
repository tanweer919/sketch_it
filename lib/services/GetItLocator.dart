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
import 'RoomService.dart';
import '../Providers/AppProvider.dart';
import '../models/User.dart';
import '../Providers/RoomProvider.dart';
import '../models/Room.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<SocketIOService>(() => SocketIOService());
  locator.registerLazySingleton<RouterService>(() => RouterService());
  locator.registerLazySingleton<SocketStream>(() => SocketStream());
  locator.registerLazySingleton<DynamicLinkService>(() => DynamicLinkService());
  locator.registerLazySingleton<HttpService>(() => HttpService());
  locator
      .registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<UserService>(() => UserService());
  locator.registerLazySingleton<RoomService>(() => RoomService());
  locator
      .registerFactoryParam<PaintProvider, List<Point>, Map<String, dynamic>>(
    (points, options) => PaintProvider(
      points,
      options["strokeWidth"],
      options["optionsIndex"],
      options["backgroundColor"],
      options["strokeColor"],
    ),
  );
  locator.registerFactoryParam<RoomProvider, Map<String, dynamic>, void>(
    (initialData, _) => RoomProvider(
      Room(
        id: initialData["roomId"],
        messages: initialData["messages"],
        players: initialData["players"],
        admin: initialData["admin"],
      ),
      initialData["status"],
      initialData["gameStatus"],
      initialData["sketcher"]
    ),
  );
  locator.registerFactoryParam<AppProvider, User, void>(
      (user, _) => AppProvider(user));
}
