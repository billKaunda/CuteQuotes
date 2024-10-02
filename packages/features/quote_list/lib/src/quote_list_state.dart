part of 'quote_list_bloc.dart';

class QuoteListState extends Equatable {
  const QuoteListState({
    this.itemList,
    this.nextPage,
    this.error,
    this.filter,
    this.refreshError,
    this.favoriteToggleError,
  });

  //Holds all of the items from the pages you have loaded so far
  final List<Quote>? itemList;

  //Next page to be fetched, or return `null` if you have already
  // loaded the entire list.
  //
  //This variable also determines whether you need a loading indicator
  // at the bottom to indicate that you haven't loaded all the pages
  // yet.
  final int? nextPage;

  //Indicates that an error occured trying to fetch any page of quotes
  //
  // If both this property and [itemList] holds values, it means that
  // an error occured when trying to fetch a subsequent page. On the
  // other hand, if this property has a value but [itemList] doesn't,
  // that means the error ocurred when fetching the first page.
  final dynamic error;

  //Currenty applied filter(if any)
  //
  //Can either be a tagFilter('QuoteListFilterByTag'), searchTerm filter
  // ('QuoteListFilterBySearchTerm'), or a favorites-only one
  // ('QuoteListFilterByFavorites').
  final QuoteListFilter? filter;

  //Indicates an error occured when trying to refresh the list
  //
  // Used to display a snackbar to indicate the failure
  final dynamic refreshError;

  //Indicates that an error occured when trying to favorite a quote
  //
  // Used to display a snackbar to the user indicating the failure
  // and also redirecting the user to the sign in screen in case
  // the cause of the error is the user being signed out.
  final dynamic favoriteToggleError;

  //Auxilliary constructor that facilitates building the state for
  // when the app is loading a tag change.
  QuoteListState.loadingNewTag({
    required Tag? tag,
  }) : this(
          filter: tag != null ? QuoteListFilterByTag(tag) : null,
        );

  //Auxilliary constructor that facilitates building the state for
  // when the app is loading a search change
  QuoteListState.loadingNewSearchTerm({
    required String searchTerm,
  }) : this(
          filter: searchTerm.isEmpty
              ? null
              : QuoteListFilterBySearchTerm(searchTerm),
        );
  // Auxilliary constructor which helps in building the state for the
  // app when loading a filter by favorites
  const QuoteListState.loadingToggledFilterByFavorites(
      {required bool isFilteringByFavorites})
      : this(
          filter: isFilteringByFavorites
              ? const QuoteListFilterByFavorites()
              : null,
        );

  //Auxilliary constructor which facilitates building the state for
  // when the app couldn't find any items for the selected filter.
  const QuoteListState.noItemsFound({
    required QuoteListFilter? filter,
  }) : this(
          itemList: const [],
          error: null,
          nextPage: 1,
          filter: filter,
        );

  //Auxilliary constructor which facilitates building the state for
  // the app when a new page has been loaded successfully
  const QuoteListState.success({
    required int? nextPage,
    required List<Quote> itemList,
    required QuoteListFilter? filter,
    required bool isRefresh,
  }) : this(
          nextPage: nextPage,
          itemList: itemList,
          filter: filter,
        );

  //Auxilliary function that creates a copy of the current state with
  // a new value for the [error] property.
  QuoteListState copyWithNewError(
    dynamic error,
  ) =>
      QuoteListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: refreshError,
      );

  //Auxilliary function which creates a copy of the current state with
  // a new value for the [refreshError] property.
  QuoteListState copyWithNewRefreshError(
    dynamic refreshError,
  ) =>
      QuoteListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: refreshError,
        favoriteToggleError: null,
      );

  //Auxilliary function which creates a copy of the current state
  // by replacing just the [updatedQuote]
  QuoteListState copyWithUpdatedQuote(
    Quote updatedQuote,
  ) =>
      QuoteListState(
        itemList: itemList?.map((quote) {
          if (quote.id == updatedQuote.id) {
            return updatedQuote;
          } else {
            return quote;
          }
        }).toList(),
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: null,
        favoriteToggleError: null,
      );

  //Auxilliary function which creates a copy of the current state
  // with a new value for the [favoriteToggleError] property.
  QuoteListState copyWithFavoriteToggleError(
    dynamic favoriteToggleError,
  ) =>
      QuoteListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: refreshError,
        favoriteToggleError: favoriteToggleError,
      );

  PagingState<int, Quote> toPagingState({
    int? nextPageKey,
    List<Quote>? itemList,
    dynamic error,
  }) {
    return PagingState<int, Quote>(
      itemList: itemList,
      nextPageKey: nextPage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        itemList,
        nextPage,
        error,
        filter,
        refreshError,
        favoriteToggleError,
      ];
}

abstract class QuoteListFilter extends Equatable {
  const QuoteListFilter();

  @override
  List<Object?> get props => [];
}

class QuoteListFilterByTag extends QuoteListFilter {
  const QuoteListFilterByTag(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [
        tag,
      ];
}

class QuoteListFilterBySearchTerm extends QuoteListFilter {
  const QuoteListFilterBySearchTerm(this.searchTerm);

  final String searchTerm;

  @override
  List<Object?> get props => [
        searchTerm,
      ];
}

class QuoteListFilterByFavorites extends QuoteListFilter {
  const QuoteListFilterByFavorites();
}
