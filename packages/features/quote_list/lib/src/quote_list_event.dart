part of 'quote_list_bloc.dart';

abstract class QuoteListEvent extends Equatable {
  const QuoteListEvent();

  @override
  List<Object?> get props => [];
}

class QuoteListFilterByFavoritesToggled extends QuoteListEvent {
  const QuoteListFilterByFavoritesToggled();
}

class QuoteListTagChanged extends QuoteListEvent {
  const QuoteListTagChanged({
    this.tag,
  });

  final Tag? tag;

  @override
  List<Object?> get props => [
        tag,
      ];
}

class QuoteListSearchTermChanged extends QuoteListEvent {
  const QuoteListSearchTermChanged(
    this.searchTerm,
  );

  final String searchTerm;

  @override
  List<Object?> get props => [
        searchTerm,
      ];
}

class QuoteListRefreshed extends QuoteListEvent {
  const QuoteListRefreshed();
}

class QuoteListNextPageRequested extends QuoteListEvent {
  const QuoteListNextPageRequested({
    required this.pageNumber,
  });

  final int pageNumber;

  @override
  List<Object?> get props => [
        pageNumber,
      ];
}

abstract class QuoteListItemFavoriteToggled extends QuoteListEvent {
  const QuoteListItemFavoriteToggled(
    this.id,
  );

  final int id;
}

class QuoteListItemFavorited extends QuoteListItemFavoriteToggled {
  const QuoteListItemFavorited(
    super.id,
  );
}

class QuoteListItemUnfavorited extends QuoteListItemFavoriteToggled {
  const QuoteListItemUnfavorited(
    super.id,
  );
}

class QuoteListFailedFetchRetried extends QuoteListEvent {
  const QuoteListFailedFetchRetried();
}

class QuoteListUsernameObtained extends QuoteListEvent {
  const QuoteListUsernameObtained();
}

class QuoteListItemUpdated extends QuoteListEvent {
  const QuoteListItemUpdated(
    this.updatedQuote,
  );

  final Quote updatedQuote;
}
