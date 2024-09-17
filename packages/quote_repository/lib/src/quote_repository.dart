import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:meta/meta.dart';
import 'package:quote_repository/src/mappers/mappers.dart';
import 'package:quote_repository/src/quote_local_storage.dart';

/*
When should you require class dependencies inside the constructor 
or when should you instantiate them by yourself inside the class?
Depends

Class dependencies whose files are located inside the same package 
you are working on should be instantiated inside the constructor. This
is the case for QuoteLocalStorage

Class dependencies that come from other internal packages, like
KeyValueStorage and FavQsApi must be received in the constructor.

This is because classes that come from other packages are highly likely
to be used by another internal package as well, for instance, FavQsApi 
is also used by the user_repository. Requiring the dependency to be
passed in the constructor, rather than instantiating it within the 
constructor, allows you to share the same instance across all places
that use it.
*/
enum QuoteListPageFetchPolicy {
  //Emit the cached quotes first, if any, and then the quotes from
  // the network calls if the HTTP call succeeds. This is very
  //useful when the user first opens the app
  cacheAndNetwork,

  //Don't use the cache info at all. If the server request fails, let
  // the user know. Useful when the user consciously refreshes the list
  networkOnly,

  //Prefer using the server, if it fails, then fallback to the cache.
  // If there cache is empty, let the user know that an error occured.
  //Useful when the user requests a subsequent page.
  networkPreferably,

  //Prefer using the cache and if it's empty, try using the server.
  //Useful when the user clears a tag or search box to show
  // him the previous state of the screen
  cachePreferably,
}

class QuoteRepository {
  QuoteRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting QuoteLocalStorage? localStorage,
  }) : _localStorage = localStorage ??
            QuoteLocalStorage(
              keyValueStorage: keyValueStorage,
            );

  final FavQsApi remoteApi; //remote data source
  final QuoteLocalStorage _localStorage; //cache data source

  Stream<QuoteListPage> getQuoteListPage(
    int pageNum, {
    Tag? tag,
    String searchTerm = '',
    String? favoritedByUsername,
    required QuoteListPageFetchPolicy fetchPolicy,
  }) async* {
    final isFilteringByTag = tag != null;
    final isSearching = searchTerm.isNotEmpty;
    final isFetchPolicyNetworkOnly =
        fetchPolicy == QuoteListPageFetchPolicy.networkOnly;
    final shouldSkipCacheLookup =
        isFilteringByTag || isSearching || isFetchPolicyNetworkOnly;

    if (shouldSkipCacheLookup) {
      //Fetch policy is networkOnly
      final freshPage = await _getQuoteListPageFromNetwork(
        pageNum,
        tag: tag,
        searchTerm: searchTerm,
        favoritedByUsername: favoritedByUsername,
      );

      yield freshPage;
    } else {
      final isFilteringByFavorites = favoritedByUsername != null;

      final cachedPage = await _localStorage.getQuoteListPage(
        pageNum,
        isFilteringByFavorites,
      );

      final isFetchPolicyCacheAndNetwork =
          fetchPolicy == QuoteListPageFetchPolicy.cacheAndNetwork;

      final isFetchPolicyCachePreferably =
          fetchPolicy == QuoteListPageFetchPolicy.cachePreferably;

      final shouldEmitCachedPageInAdvance =
          isFetchPolicyCacheAndNetwork || isFetchPolicyCachePreferably;

      if (shouldEmitCachedPageInAdvance && cachedPage != null) {
        //Since the cachedPage is a QuoteListPageCM object, call the
        // mapper function to convert it to domain QuoteListPage object.
        yield cachedPage.toDomainModel();
        if (isFetchPolicyCachePreferably) {
          //If the the fetch policy is cachePreferably and you've
          // already emitted the cached page successfully, there's
          // nothing else to do. Just return and close the Stream
          return;
        }
      }
      //Call the remote API
      try {
        final freshPage = await _getQuoteListPageFromNetwork(
          pageNum,
          favoritedByUsername: favoritedByUsername,
        );

        yield freshPage;
      } catch (_) {
        final isFetchPolicyNetworkPreferably =
            fetchPolicy == QuoteListPageFetchPolicy.networkPreferably;

        //If the fetchPolicy is networkPreferably and you got an error
        // trying to fetch a page from the server, try to revert the
        // error by emitting the cached page instead, if there is one.
        if (cachedPage != null && isFetchPolicyNetworkPreferably) {
          yield cachedPage.toDomainModel();
          return;
        }
        //Since you've already emitted the cachedPage if the the policy
        // is cacheAndNetwork or cachePreferably earlier, if the network
        // call still fails, your only option now is tor rethrow the error.
        // This way, the state manager will handle it properly by showing
        // the user an error.
        rethrow;
      }
    }
  }

  Future<QuoteListPage> _getQuoteListPageFromNetwork(
    int pageNum, {
    Tag? tag,
    String searchTerm = '',
    String? favoritedByUsername,
  }) async {
    try {
      //Get a new page from the api
      final apiPage = await remoteApi.getQuoteListPage(
        pageNum,
        tag: tag?.toRemoteModel(),
        searchTerm: searchTerm,
        favoritedByUsername: favoritedByUsername,
      );

      final isFiltering = tag != null || searchTerm.isNotEmpty;
      final favoritesOnly = favoritedByUsername != null;

      //Don't cache filtered results. If you tried to cache all the
      // searches the user could possibly perform, you'll quickly
      // fill up the device's storage.
      //Also, users are willing to wait longer for searches.
      final shouldStoreOnCache = !isFiltering;
      if (shouldStoreOnCache) {
        final shouldEmptyCache = pageNum == 1;

        //Every time you get a fresh first page, clear all the subsequent
        // ones previously stored on cache. This forces the subsequent
        // pages to be fetched from the network in the future, so, you
        // don't risk mixing updated and outdated pages.
        // Not doing this can result into a problem, such as, if a quote
        // that used to be on the second page moved to the first page, you'd
        // risk showing that quote twice if you mixed the cached and fresh
        // pages.
        if (shouldEmptyCache) {
          await _localStorage.clearQuoteListPageList(favoritesOnly);
        }

        final cachePage = apiPage.toCacheModel();
        await _localStorage.upsertQuoteListPage(
          pageNum,
          cachePage,
          favoritesOnly,
        );
      }

      final domainPage = apiPage.toDomainModel();
      return domainPage;
    } on EmptySearchResultFavQsException catch (_) {
      throw EmptySearchResultException();
    }
  }

  Future<Quote> getQuoteDetails(int id) async {
    final cachedQuote = await _localStorage.getQuote(id);
    if (cachedQuote != null) {
      return cachedQuote.toDomainModel();
    } else {
      final apiQuote = await remoteApi.getQuote(id);
      return apiQuote.toDomainModel();
    }
  }

  Future<Quote> favoriteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.favoriteQuote(id).toCacheUpdateFuture(
              _localStorage,
              shouldInvalidateFavoritesCache: true,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> unfavoriteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.unfavoriteQuote(id).toCacheUpdateFuture(
              _localStorage,
              shouldInvalidateFavoritesCache: true,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> upvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.upvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> downvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.upvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> unvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.upvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<void> clearCache() async {
    await _localStorage.clear();
  }
}

extension on Future<QuoteRM> {
  Future<QuoteCM> toCacheUpdateFuture(
    QuoteLocalStorage localStorage, {
    bool shouldInvalidateFavoritesCache = false,
  }) async {
    try {
      final updatedApiQuote = await this;
      final updatedCacheQuote = updatedApiQuote.toCacheModel();
      await Future.wait([
        localStorage.updateQuote(
          updatedCacheQuote,
          !shouldInvalidateFavoritesCache,
        ),
        if (shouldInvalidateFavoritesCache)
          localStorage.clearQuoteListPageList(true)
      ]);
      return updatedCacheQuote;
    } catch (error) {
      if (error is UserAuthRequiredFavQsException) {
        throw UserAuthenticationRequiredException();
      }
      rethrow;
    }
  }
}
