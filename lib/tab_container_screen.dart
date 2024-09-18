import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:routemaster/routemaster.dart';
import 'package:cutequotes/l10n/app_localizations.dart';

class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    //CupertinoTabPage is a class that comes from routemaster package.
    // This class gives you a controller and tabBuilder to set up 
    // the tabbed layout structure using Flutter's CupertinoTabScaffold.
    //
    final tabState = CupertinoTabPage.of(context);

    /*
    C
    */
    return CupertinoTabScaffold(
      //controls the state of the bottom bar-which index is selected, e.t.c 
      controller: tabState.controller,
      //Builds the inner screens you want to display for each tab.
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: l10n.quotesBottomNavigationBarItemLabel,
            icon: const Icon(
              Icons.format_quote,
            ),
          ),
          BottomNavigationBarItem(
            label: l10n.profileBottomNavigationBarItemLabel,
            icon: const Icon(
              Icons.person,
            ),
          ),
        ],
      ),
    );
  }
}
