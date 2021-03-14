import 'package:flutter/cupertino.dart';
import '../screens/CreateRoomScreen.dart';
import '../screens/Home.dart';
import '../screens/GameScreen.dart';
import '../screens/ShareRoomScreen.dart';
import '../commons/CircularRevealClipper.dart';
import '../screens/IntroductionScreen.dart';

class RouterService {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  Route<dynamic> generateRoutes(RouteSettings settings) {
    final List<String> validRoutes = [
      '/home',
      '/join',
      '/createroom',
      '/shareroom',
      '/introduction'
    ];
    if (validRoutes.contains(settings.name)) {
      return customRoutes(settings.name, settings.arguments);
    }
  }

  PageRouteBuilder<dynamic> customRoutes(
      String route, Map<String, dynamic> args) {
    String message;
    String roomId;
    Offset offset;
    bool roomCreated;
    Map<String, dynamic> initialRoomData;
    if (args != null) {
      if (args.containsKey("message")) {
        message = args["message"];
      }
      if (args.containsKey("roomId")) {
        roomId = args["roomId"];
      }
      if (args.containsKey("offset")) {
        offset = args["offset"];
      }
      if(args.containsKey("roomCreated")) {
        roomCreated = args["roomCreated"];
      }
      if(args.containsKey("initialRoomData")) {
        initialRoomData = args["initialRoomData"];
      }
    }
    Map<String, Widget> screens = {
      '/home': HomeScreen(),
      '/join': GameScreen(roomId: roomId, roomCreated: roomCreated, initialRoomData: initialRoomData),
      '/createroom': CreateRoomScreen(),
      '/shareroom': ShareRoomScreen(
        message: message,
        roomId: roomId,
      ),
      '/introduction': IntroductionScreen()
    };
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screens[route],
      transitionsBuilder: (_, anim, __, child) => route == '/shareroom'
          ? SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(anim),
              child: child,
            )
          : route == '/createroom'
              ? ClipPath(
                  clipper: CircularRevealClipper(
                    fraction: anim.value,
                    centerAlignment: Alignment.center,
                    centerOffset: offset,
                    minRadius: 0,
                    maxRadius: 800,
                  ),
                  child: child,
                )
              : FadeTransition(
                  opacity: anim,
                  child: child,
                ),
      transitionDuration: Duration(
          milliseconds:
              route == '/shareroom' || route == '/createroom' ? 500 : 250),
    );
  }
}
