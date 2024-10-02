import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain_models/domain_models.dart';
import 'package:user_repository/user_repository.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'quote_list_state.dart';

part 'quote_list_event.dart';

class QuoteListBloc extends Bloc<QuoteListEvent, QuoteListState> {
  QuoteListBloc({
    required UserRepository userRepository,
    required QuoteRepository quoteRepository,
  })  : _quoteRepository = quoteRepository,
        super(
          const QuoteListState(),
        ) {
    _registerEventHandler();

    //Watch the user's authentication status
    // The getUser() function returns a Stream<User?> as it monitors the
    // changes in the user's authentication status. When the user signs in,
    // a new object comes down that channel, and when he signs out, you
    // get a null value.
    // You subscribe to the Stream using the listen() function which returns
    // a subscription object which is stored in the _authChangesSubscription
    // property
    _authChangesSubscription = userRepository.getUser().listen(
      (user) {
        //Every time you get a new value from getUser() stream, you
        //store the new username inside the _authenticatedUsername
        // property. This allows you to read that value from other
        // parts of your Bloc code.
        _authenticatedUsername = user?.username;

        add(
          const QuoteListUsernameObtained(),
        );
      },
    );
  }

  late final StreamSubscription _authChangesSubscription;
  final QuoteRepository _quoteRepository;
  String? _authenticatedUsername;

  void _registerEventHandler() {
    on<QuoteListEvent>((event, emitter) async {
      if (event is QuoteListUsernameObtained) {
        await _handleQuoteListUsernameObtained(emitter);
      } else if (event is QuoteListFailedFetchRetried) {
        await _handleQuoteListFailedFetchRetried(emitter);
      } else if (event is QuoteListItemUpdated) {
        _handleQuoteListItemUpdated(emitter, event);
      } else if (event is QuoteListTagChanged) {
        await _handleQuoteListTagChanged(emitter, event);
      } else if (event is QuoteListSearchTermChanged) {
        await _handleQuoteListSearchTermChanged(emitter, event);
      } else if (event is QuoteListRefreshed) {
        await _handleQuoteListRefreshed(emitter, event);
      } else if (event is QuoteListNextPageRequested) {
        await _handleQuoteListNextPageRequested(emitter, event);
      } else if (event is QuoteListItemFavoriteToggled) {
        await _handleQuoteListItemFavoriteToggled(emitter, event);
      } else if (event is QuoteListFilterByFavoritesToggled) {
        await _handleQuoteListFilterByFavoritesToggled(emitter);
      }
      //transformer argument of the on() function gives you the ability
      // to customize your events. Overriding the transformer argument
      // is the factor you should consider when deciding to pick Blocs
      // over Cubits for a specific screen.
    }, transformer: (eventStream, eventHandler) {
      /*
      ---eventStream is the channel/Stream through which our events
      come in.
      ---eventHandler is the function written above which processes 
      the events.
      */

      //The where operator generates a new Stream which excludes any
      // QuoteListSearchTermChanged events.
      final nonDebounceEventStream = eventStream.where(
        (event) => event is! QuoteListSearchTermChanged,
      );

      //Debounce search events. The whereType operator here generates
      // a new Stream which excludes all but the QuoteListSearchTermChanged
      // events.
      final debounceEventStream = eventStream
          .whereType<QuoteListSearchTermChanged>()
          .debounceTime(
            const Duration(seconds: 1),
          )
          /*
          Skip searches where the term entered by the user is equal to 
          the term of the search already on display. This can happen, for
          instance when a user types a letter in the search bar, then
          regrets it and deletes it within 1sec.
          Without applying this where operator, this would trigger another
          request although the search term hasn't changed
          */
          .where((event) {
        final previousFilter = state.filter;
        final previousSearchTerm = previousFilter is QuoteListFilterBySearchTerm
            ? previousFilter.searchTerm
            : '';

        return event.searchTerm != previousSearchTerm;
      });

      //Merge the two Streams back together.
      final mergedEventStream = MergeStream([
        nonDebounceEventStream,
        debounceEventStream,
      ]);

      //Apply the canceling effect by discarding in-progress event if
      // a new one comes in.

      /*
      restartable function, coming from the bloc_concurrency package,
      is the one that has the desired canceling effect. The package
      also provide a few different options as well.

      restartable function actually returns another function. Return
      the results from that function by passing them to your 
      mergedEventStream and eventHandler
      */
      final restartableTransformer = restartable<QuoteListEvent>();
      return restartableTransformer(mergedEventStream, eventHandler);
    });
  }

  //QuoteListUsernameObtained event is fired from the constructor
  // when a user first opens the screen and you've retrieved their
  // username or null, or when the user signs in or out at a later
  // time.
  Future<void> _handleQuoteListUsernameObtained(Emitter emitter) {
    //Use the emitter to set the UI back to its initial state-with a
    // full screen loading indicator- while keeping any filters the
    // user might have selected, e.g, a tag
    emitter(
      QuoteListState(
        filter: state.filter,
      ),
    );

    //Call the _fetchQuotePage function to get a new Stream that
    // you can subscribe to, to get the initial page.
    final firstPageFetchStream = _fetchQuotePage(
      1,
      fetchPolicy: QuoteListPageFetchPolicy.cacheAndNetwork,
    );

    //Use the onEach() method of the emitter to handle subscribing to
    // the firstPageFetchStream and sending out each new state it emits
    // to the UI.
    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleQuoteListFailedFetchRetried(Emitter emitter) {
    //Clears out the error and puts the loading indicator back on
    // the screen.
    emitter(
      state.copyWithNewError(null),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      fetchPolicy: QuoteListPageFetchPolicy.cacheAndNetwork,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  void _handleQuoteListItemUpdated(
    Emitter emitter,
    QuoteListItemUpdated event,
  ) {
    //Replaces the updated quote in the current state and re-emits it.
    emitter(
      state.copyWithUpdatedQuote(event.updatedQuote),
    );
  }

  Future<void> _handleQuoteListTagChanged(
    Emitter emitter,
    QuoteListTagChanged event,
  ) {
    emitter(
      QuoteListState.loadingNewTag(tag: event.tag),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      /*
      If the user is 'deselecting' a tag, the 'cachePreferably'
      fetch policy will return the cached quotes. However, if 
      the user is selecting a new tag, 'cachePreferably' won't
      find any cached quotes and will instead use the network.
      */
      fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleQuoteListSearchTermChanged(
    Emitter emitter,
    QuoteListSearchTermChanged event,
  ) {
    emitter(
      QuoteListState.loadingNewSearchTerm(
        searchTerm: event.searchTerm,
      ),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      /*
      If the user is 'clearing out' the seach bar, the 
      'cachePreferably' fetch policy will return the cached quotes.
      However, if the user is entering a new search, 
      'cachePreferably' won't find anything and will opt to 
      network.
      */
      fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleQuoteListRefreshed(
    Emitter emitter,
    QuoteListRefreshed event,
  ) {
    final firstPageFetchStream = _fetchQuotePage(
      1,
      /*
      Because the user is asking for a refresh, he doesn't want to 
      get cached quotes, thus 'networkOnly' fetch makes the sense.
      */
      fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleQuoteListNextPageRequested(
    Emitter emitter,
    QuoteListNextPageRequested event,
  ) {
    emitter(
      state.copyWithNewError(null),
    );

    final nextPageFetchStream = _fetchQuotePage(
      event.pageNumber,
      /*
      The 'networkPreferably' fetch policy prioritizes fetching the 
      new page from the server, and if it fails, try grabbing from 
      the cache.
      */
      fetchPolicy: QuoteListPageFetchPolicy.networkPreferably,
    );
    return emitter.onEach<QuoteListState>(
      nextPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleQuoteListItemFavoriteToggled(
    Emitter emitter,
    QuoteListItemFavoriteToggled event,
  ) async {
    try {
      // The favoriteQuote() and unfavoriteQuote() methods return
      // you the updated quote object.

      final updatedQuote = await (event is QuoteListItemFavorited
          ? _quoteRepository.favoriteQuote(
              event.id,
            )
          : _quoteRepository.unfavoriteQuote(
              event.id,
            ));

      final isFilteringByFavorites = state.filter is QuoteListFilterByFavorites;

      //If the user isn't filtering by favorites, you just replace the
      //changed quote on-screen.
      if (!isFilteringByFavorites) {
        emitter(
          state.copyWithUpdatedQuote(updatedQuote),
        );
      } else {
        /*
        If the user is filtering by favorites, that means the user is 
        actually removing a quote from the list. Therefore, you need to 
        refresh the entire list to ensure that you don't break pagination
        */
        emitter(
          QuoteListState(filter: state.filter),
        );
      }

      final firstPageFetchStream = _fetchQuotePage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
      );

      await emitter.onEach<QuoteListState>(
        firstPageFetchStream,
        onData: emitter.call,
      );
    } catch (error) {
      /*
      If an error occurs when trying to (un)favorite a quote, attach
      the error to the current state which will result in displaying
      a snackbar to the user and possibly taking him to the Sign In 
      screen in case he is signed out.
      */
      emitter(
        state.copyWithFavoriteToggleError(error),
      );
    }
  }

  Future<void> _handleQuoteListFilterByFavoritesToggled(
    Emitter emitter,
  ) {
    final isFilteringByFavorites = state.filter is! QuoteListFilterByFavorites;

    emitter(
      QuoteListState.loadingToggledFilterByFavorites(
        isFilteringByFavorites: isFilteringByFavorites,
      ),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      /*
      If the user is 'adding' the favorites filter, use the 
      'cacheAndNetwork' fetch policy to show the cached data first 
      followed by the updated list from the server.
      If the user is 'removing' the favorites filter, just show the 
      cached data they were seeing before applying the filter.
      */
      fetchPolicy: isFilteringByFavorites
          ? QuoteListPageFetchPolicy.cacheAndNetwork
          : QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  //This utility function fetches a given page
  Stream<QuoteListState> _fetchQuotePage(
    int page, {
    required QuoteListPageFetchPolicy fetchPolicy,
    bool isRefresh = false,
  }) async* {
    //Retrieve the currently applied filter, which can be a search
    // filter, tag filter or favorites filter
    final currentlyAppliedFilter = state.filter;

    final isFilteringByFavorites =
        currentlyAppliedFilter is QuoteListFilterByFavorites;

    final isUserSignedIn = _authenticatedUsername != null;

    if (isFilteringByFavorites && !isUserSignedIn) {
      yield QuoteListState.noItemsFound(
        filter: currentlyAppliedFilter,
      );
    } else {
      //Fetch the page
      final pageStream = _quoteRepository.getQuoteListPage(
        page,
        tag: currentlyAppliedFilter is QuoteListFilterByTag
            ? currentlyAppliedFilter.tag
            : null,
        searchTerm: currentlyAppliedFilter is QuoteListFilterBySearchTerm
            ? currentlyAppliedFilter.searchTerm
            : '',
        favoritedByUsername:
            currentlyAppliedFilter is QuoteListFilterByFavorites
                ? _authenticatedUsername
                : null,
        fetchPolicy: fetchPolicy,
      );

      try {
        // Listen to the stream you got from the repository by
        // using the await for syntax.
        await for (final newPage in pageStream) {
          final newItemList = newPage.quoteList;
          final oldItemList = state.itemList ?? [];

          //For every new page you get, append the new items to
          // the old ones already on the screen. This is assuming
          // the user isn't trying to refresh the page, which will
          // necessitate replacing the previous items.
          final completeList = isRefresh || page == 1
              ? newItemList
              : (oldItemList + newItemList);

          final nextPage = newPage.isLastPage ? null : page + 1;

          //yield a new QuoteListState containing all the data you
          // got from the repository
          yield QuoteListState.success(
            nextPage: nextPage,
            itemList: completeList,
            filter: currentlyAppliedFilter,
            isRefresh: isRefresh,
          );
        }
      } catch (error) {
        //Handle errors if you can't get a new page for some reason
        //such as the user not having an internet connection

        if (error is EmptySearchResultException) {
          yield QuoteListState.noItemsFound(
            filter: currentlyAppliedFilter,
          );
        }

        //If error occured during a refresh request, notify the user
        //of it using a snackbar and if it is an unexpected error,
        // just re-emit the current state with an error added to it.
        if (isRefresh) {
          yield state.copyWithNewRefreshError(
            error,
          );
        } else {
          yield state.copyWithNewError(error);
        }
      }
    }
  }

  //Dispose the authChangesSubscription created when the screen
  // is closed. It ensure that the subscription won't remain active
  // after the user closes the screen
  @override
  Future<void> close() {
    _authChangesSubscription.cancel();
    return super.close();
  }
}
