import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'GetItLocator.dart';
import 'RouterService.dart';

class DynamicLinkService {
  final RouterService _routerService = locator<RouterService>();

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

  void _handleDeepLink(PendingDynamicLinkData data) {
    final Uri deeplink = data?.link;
    if (deeplink != null) {
      print('deeplink $deeplink');
      print(deeplink.pathSegments.toString());
      final String route = '/${deeplink.pathSegments.first}';
      print(route);
      print(deeplink.queryParameters);
      _routerService.navigationKey.currentState.pushReplacementNamed(route,
          arguments: {
            deeplink.queryParameters['key']:
                int.parse(deeplink.queryParameters['value'])
          });
    }
  }

  Future<String> createRoomLink(int roomId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://sketchit.page.link',
      link: Uri.parse('https://sketchit.page.link/join?key=roomId&value=${roomId}'),
      androidParameters: AndroidParameters(
        packageName: 'com.sketch_it',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: "Join room",
          imageUrl: Uri.parse(
              "https://www.brightful.me/content/images/size/w2000/2020/08/pictionary.jpg")),
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl.toString();
  }
}
