import 'package:key_value_storage/key_value_storage.dart';
import 'package:domain_models/domain_models.dart';

extension QuoteListPageCMtoDomain on QuoteListPageCM {
  QuoteListPage toDomainModel() {
    return QuoteListPage(
      isLastPage: isLastPage,
      quoteList: quoteList.map((quote) => quote.toDomainModel()).toList(),
    );
  }
}

extension QuoteCMtoDomain on QuoteCM {
  Quote toDomainModel() {
    return Quote(
      id: id,
      body: body,
      author: author,
      favoritesCount: favoritesCount,
      upvotesCount: upvotesCount,
      downvotesCount: downvotesCount,
      isUpvoted: isUpvoted,
      isDownvoted: isDownvoted,
      isFavorite: isFavorite,
    );
  }
}

/*
Mappers are functions that takes an object from one model and return
an object from another. This is because property types in different 
models can differ, for instance, sth that's a String for the API could
be an enum for the database.
*/