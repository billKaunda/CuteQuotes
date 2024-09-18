/*
Dynamic links is no longer supported, as at 25th Aug, 2024 and
will stop working on 25th Aug, 2025
*/

import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

typedef OnNewDynamicLinkPath = void Function(String newDynamicLinkPath);

///Wrapper around [FirebaseDynamicLinks]
class DynamicLinkService {
  static const _domainUriPrefix = 'https://wonderwords952.page.link';
  static const _iosBundleId = 'com.billkaunda.cuteQuotes';
  static const _androidPackageName = 'com.billkaunda.cute_quotes';

  DynamicLinkService({
    @visibleForTesting FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  final FirebaseDynamicLinks _dynamicLinks;

  //This function generates a dynamic link
  Future<String> generateDynamicLinkUrl({
    //Path of the screen you want your screen to open
    required String path,
    //This optional parameter contains info you'd like to appear when
    // your link is shared in a social post, such as a short description
    // or image.
    SocialMetaTagParameters? socialMetaTagParameters,
  }) async {
    //Build a DynamicLinkParameters object by combining the parameters
    // you received (e.g socialMetaTagParameters) with those you have built
    // already; the static consts you have written above.
    final parameters = DynamicLinkParameters(
      uriPrefix: _domainUriPrefix,
      link: Uri.parse(
        '$_domainUriPrefix$path',
      ),
      androidParameters: const AndroidParameters(
        packageName: _androidPackageName,
      ),
      iosParameters: const IOSParameters(
        bundleId: _iosBundleId,
      ),
      socialMetaTagParameters: socialMetaTagParameters,
    );

    //Delegate link construction to the buildShortLink() function from
    // the FirebaseDynamicLinks class.
    final shortLink = await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  //This function returns the link that opened the app. If the app is
  // launched from a dynamic link, this function will return that link
  // to you so you can navigate to the corresponding screen.
  Future<String?> getInitialDynamicLinkPath() async {
    final data = await _dynamicLinks.getInitialLink();
    final link = data?.link;
    return link?.path;
  }

  //This property exposes a Stream<String> so that users of this function
  // can listen to get notified about an incoming new link.
  Stream<String> onNewDynamicLinkPath() {
    // FirebaseDynamicLinks class contains an onLink property. Use the map
    // function to chage the data type from PendingDynamicLinkData to a
    // String containing the path of the screen you need to open-which is
    // the only thing required for navigation.
    return _dynamicLinks.onLink.map(
      (PendingDynamicLinkData data) {
        final link = data.link;
        final path = link.path;
        return path;
      },
    );
  }
}
