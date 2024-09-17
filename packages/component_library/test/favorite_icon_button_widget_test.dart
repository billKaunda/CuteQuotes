import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoriteIconButton tests: ', () {
    final locale = Locale('en');
    final localizationsDelegates = const [
      ComponentLibraryLocalizations.delegate
    ];
    testWidgets(
        'Check whether the onTap() callback is executed when '
        'FavoriteIconButton is pressed', (tester) async {
      //Initialize the variable that will be manipulated in the onTap
      // gesture
      bool value = false;

      //The pumpWidget function helps build the widget.
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        home: Scaffold(
          body: FavoriteIconButton(
            isFavorite: false,
            onTap: () => value = !value,
          ),
        ),
      ));

      //Here the widget is being tapped.
      await tester.tap(find.byType(FavoriteIconButton));

      expect(value, true);
    });
    testWidgets(
        'When isFavorite flag is set to false, return Icons.favorite'
        '_border_outlined', (tester) async {
      final bool isFavorite = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: localizationsDelegates,
          home: Scaffold(
            body: FavoriteIconButton(isFavorite: isFavorite),
          ),
        ),
      );

      tester.widget(find.byIcon(Icons.favorite_border_outlined));

      expect(isFavorite, false);
    });
  });
}
