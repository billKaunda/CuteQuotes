import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:cutequotes/tab_container_screen.dart';
import 'package:domain_models/domain_models.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:monitoring/monitoring.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:update_profile/update_profile.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_details/quote_details.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,

  // DynamicLinkService is no longer supported
  //required DynamicLinkService dynamicLinkService,
}) {
  return {
    //Wraps TabContainerScreen widget insider a CupertinoTabPage class
    // to achieve a nested navigation layout
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.quoteListPath,
            _PathConstants.profileMenuPath,
          ],
        ),
    //Define two nested route homes
    _PathConstants.quoteListPath: (route) => MaterialPage(
          name: 'quotes-list',
          child: QuoteListScreen(
            quoteRepository: quoteRepository,
            userRepository: userRepository,
            onAuthenticationError: (context) => routerDelegate.push(
              _PathConstants.signInPath,
            ),
            onQuoteSelected: (id) {
              //QuoteDetailsPath may return a result; an updated Quote if the
              // user interacted with it while on that screen, e.g, by
              // favoriting it. You then return that Quote object to the
              // onQuoteSelected callback so that the QouteListScreen can
              // update it if sth changed.
              final navigation = routerDelegate.push<Quote?>(
                _PathConstants.quoteDetailsPath(
                  quoteId: id,
                ),
              );
              return navigation.result;
            },
            remoteValueService: remoteValueService,
          ),
        ),
    _PathConstants.profileMenuPath: (_) => MaterialPage(
          name: 'profile-menu',
          child: ProfileMenuScreen(
            quoteRepository: quoteRepository,
            userRepository: userRepository,
            onSignInTap: () => routerDelegate.push(
              _PathConstants.signInPath,
            ),
            onSignUpTap: () => routerDelegate.push(
              _PathConstants.signUpPath,
            ),
            onUpdateProfileTap: () => routerDelegate.push(
              _PathConstants.updateProfileMenuPath,
            ),
          ),
        ),
    //Define subsequent routes
    _PathConstants.updateProfileMenuPath: (_) => MaterialPage(
          name: 'update-profile-menu',
          child: UpdateProfileScreen(
            userRepository: userRepository,
            onUpdateProfileSuccess: () => routerDelegate.pop(),
          ),
        ),
    _PathConstants.quoteDetailsPath(): (info) => MaterialPage(
          name: 'quote-details',
          child: QuoteDetailsScreen(
            quoteRepository: quoteRepository,
            // info.pathParameters[_PathConstants.idPathParameter] is how
            // you extract a path parameter from a route. All path parameters
            // come to us as strings, that's the reason why parse it to an int.
            quoteId: int.tryParse(
                    info.pathParameters[_PathConstants.idPathParameter] ??
                        '') ??
                0,
            onAuthenticationError: () => routerDelegate.push(
              _PathConstants.signInPath,
            ),

            /*
            ///Dynamic Links is no longer supported
            shareableLinkGenerator: (quote) =>
                dynamicLinkService.generateDynamicLinkUrl(
              path: _PathConstants.quoteDetailsPath(
                quoteId: quote.id,
              ),
              TODO: 
              socialMetaTagParameters: SocialMetaTagParameters(
                title: quote.body,
                description: quote.author,
              ),
              */
            ),
          ),
    _PathConstants.signInPath: (_) => MaterialPage(
          name: 'sign-in',
          fullscreenDialog: true,
          child: Builder(
            builder: (context) => SignInScreen(
              userRepository: userRepository,
              onSignInSuccess: () => routerDelegate.pop(),
              onSignUpTap: () => routerDelegate.push(
                _PathConstants.signUpPath,
              ),
              onForgotMyPasswordTap: () => showDialog(
                context: context,
                builder: (context) {
                  return ForgotMyPasswordDialog(
                    userRepository: userRepository,
                    onCancelTap: () => routerDelegate.pop(),
                    onEmailRequestSuccess: () => routerDelegate.pop(),
                  );
                },
              ),
            ),
          ),
        ),
    _PathConstants.signUpPath: (_) => MaterialPage(
          name: 'sign-up',
          child: SignUpScreen(
            userRepository: userRepository,
            onSignUpSuccess: () => routerDelegate.pop(),
          ),
        ),
  };
}

//Define the app's paths
class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';

  static String get quoteListPath => '${tabContainerPath}quotes';

  static String get profileMenuPath => '${tabContainerPath}user';

  static String get updateProfileMenuPath => '$profileMenuPath/update';

  static String get signInPath => '${tabContainerPath}sign-in';

  static String get signUpPath => '${tabContainerPath}sign-up';

  static String get idPathParameter => 'id';

  static String quoteDetailsPath({
    int? quoteId,
  }) =>
      '$quoteListPath/:$idPathParameter${quoteId != null ? '/$quoteId' : 0}';
}
