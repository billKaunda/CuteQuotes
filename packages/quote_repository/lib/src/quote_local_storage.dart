import 'package:key_value_storage/key_value_storage.dart';

class QuoteLocalStorage {
  QuoteLocalStorage({required this.keyValueStorage});

  final KeyValueStorage keyValueStorage;

  Future<void> upsertQuoteListPage(
    int pageNumber,
    QuoteListPageCM quoteListPageCM,
    bool favoritesOnly,
  ) async {
    final box = await (favoritesOnly
        ? keyValueStorage.favoriteQuoteListPageBox
        : keyValueStorage.quoteListPageBox);
    return box.put(pageNumber, quoteListPageCM);
  }

  Future<void> clearQuoteListPageList(bool favoritesOnly) async {
    final box = await (favoritesOnly
        ? keyValueStorage.favoriteQuoteListPageBox
        : keyValueStorage.quoteListPageBox);
    await box.clear();
  }

  Future<void> clear() async {
    await Future.wait([
      keyValueStorage.favoriteQuoteListPageBox.then(
        (box) => box.clear(),
      ),
      keyValueStorage.quoteListPageBox.then(
        (box) => box.clear(),
      ),
    ]);
  }

  Future<QuoteListPageCM?> getQuoteListPage(
    int pageNum,
    bool favoritesOnly,
  ) async {
    final box = await (favoritesOnly
        ? keyValueStorage.favoriteQuoteListPageBox
        : keyValueStorage.quoteListPageBox);
    return box.get(pageNum);
  }

  Future<QuoteCM?> getQuote(int id) async {
    final favoritesBox = await keyValueStorage.favoriteQuoteListPageBox;
    final quotesBox = await keyValueStorage.quoteListPageBox;

    final allQuotesList = [
      ...favoritesBox.values,
      ...quotesBox.values,
    ].expand((page) => page.quoteList);

    try {
      return allQuotesList.firstWhere((quote) => quote.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateQuote(
    QuoteCM updatedQuote,
    bool shouldUpdateFavorites,
  ) async {
    final favoritesBox = await keyValueStorage.favoriteQuoteListPageBox;
    final quotesBox = await keyValueStorage.quoteListPageBox;

    final list = [
      quotesBox.updateQuote(updatedQuote),
      if (shouldUpdateFavorites) favoritesBox.updateQuote(updatedQuote)
    ];

    await Future.wait(list);
  }
}

extension on Box<QuoteListPageCM>{
    Future<void> updateQuote(QuoteCM updatedQuote) async {
      final pageList = values.toList();
      try{
        final outdatedPage = pageList.firstWhere(
          (page) => page.quoteList.any(
            (quote) => quote.id == updatedQuote.id
          ),
        );
      
      final outdatedPageIndex = pageList.indexOf(outdatedPage);

      final updatedQuotePage = QuoteListPageCM(
        isLastPage: outdatedPage.isLastPage,
        quoteList: outdatedPage.quoteList.map(
          (quote) {
            if (quote.id == updatedQuote.id) {
              return updatedQuote;
            }
            return quote;
          },
        ).toList(),
      );

      //Indexes are zero-based but page numbers are not
      final pageNum = outdatedPageIndex + 1;
      return put(pageNum, updatedQuotePage);
      }catch (_) {}
    }
  }
