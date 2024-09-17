import '../key_value_storage.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/*
This class wraps [Hive] so that we can register all adapters and
manage all keys from a single place

To use this class, just unwrap one of its exposed boxes, like 
[quoteListPageBox], and execute operations in it, for example

(await quoteListPageBox).clear();

Storing non-primitive types in Hive requires us to use incremental
[typeId]s. Having all these models and boxes in a single package
allows us avoid conflicts
*/

class KeyValueStorage {
  static const _quoteListPageBoxKey = 'quote-list-pages';
  static const _favoriteQuoteListPageBoxKey = 'favorite-quote-list-pages';
  static const _darkModePreferenceBoxKey = 'dark-mode-preference';

  KeyValueStorage({
    @visibleForTesting HiveInterface? hive,
  }) : _hive = hive ?? Hive {
    try {
      _hive
        ..registerAdapter(QuoteListPageCMAdapter())
        ..registerAdapter(QuoteCMAdapter())
        ..registerAdapter(DarkModePreferenceCMAdapter());
    } catch (_) {
      throw Exception('Don\'t have more than one [KeyValueStorage] instance in '
          'your project');
    }
  }

  final HiveInterface _hive;

  Future<Box<QuoteListPageCM>> get quoteListPageBox =>
      _openHiveBox<QuoteListPageCM>(
        _quoteListPageBoxKey,
        isTemporary: true,
      );

  Future<Box<QuoteListPageCM>> get favoriteQuoteListPageBox =>
      _openHiveBox<QuoteListPageCM>(
        _favoriteQuoteListPageBoxKey,
        isTemporary: true,
      );

  Future<Box<DarkModePreferenceCM>> get darkModePreferenceBox =>
      _openHiveBox<DarkModePreferenceCM>(_darkModePreferenceBoxKey,
          isTemporary: false);

  Future<Box<T>> _openHiveBox<T>(
    String boxKey, {
    required bool isTemporary,
  }) async {
    if (_hive.isBoxOpen(boxKey)) {
      return _hive.box(boxKey);
    } else {
      final directory = await (isTemporary
          ? getTemporaryDirectory()
          : getApplicationDocumentsDirectory());
      return _hive.openBox<T>(boxKey, path: directory.path);
    }
  }
}
