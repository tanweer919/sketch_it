import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'GetItLocator.dart';
import 'RouterService.dart';
import 'LocalStorageService.dart';
import 'RoomService.dart';
import 'SocketIOService.dart';

class DynamicLinkService {
  final RouterService _routerService = locator<RouterService>();
  final LocalStorageService _localStorage = locator<LocalStorageService>();
  final RoomService _roomService = locator<RoomService>();
  final SocketIOService _socketIOService = locator<SocketIOService>();

  Future handleDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData data) async {
      _handleDeepLink(data);
    }, onError: (OnLinkErrorException e) async {
      print('Link failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deeplink = data?.link;
    _socketIOService.onRoomJoinedUsingLink = _onRoomJoinedUsingLink;
    if (deeplink != null) {
      print('deeplink $deeplink');
      print(deeplink.pathSegments.toString());
      final String route = '/${deeplink.pathSegments.first}';
      print(route);
      print(deeplink.queryParameters);
      if (route == '/join') {
        await joinRoom(roomId: deeplink.queryParameters['value']);
      }
    }
  }

  Future joinRoom({String roomId}) async {
    final username = await _localStorage.getString('username');
    final result = await _roomService.checkRoom(roomId: roomId);
    if (result["success"]) {
      _socketIOService.joinRoom(roomId: roomId, username: username, source: "link");
    }
  }

  Future<String> createRoomLink(String roomId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://app.justsketch.in',
      link: Uri.parse(
          'https://app.justsketch.in/join?key=roomId&value=$roomId'),
      androidParameters: AndroidParameters(
        packageName: 'com.just_sketch',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'Just Sketch',
        medium: 'social',
        source: 'orkut',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Join room",
        imageUrl: Uri.parse(
            "https://www.brightful.me/content/images/size/w2000/2020/08/pictionary.jpg"),
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri dynamicUrl = shortDynamicLink.shortUrl;

    return dynamicUrl.toString();
  }

  void _onRoomJoinedUsingLink(Map<String, dynamic> data) {
    _routerService.navigationKey.currentState
        .pushReplacementNamed('/join',
        arguments: {
          "roomId": data["roomId"],
          "initialRoomData": data["initialRoomData"]
        });
  }
}
