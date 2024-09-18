import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../quote_list.dart';
import 'quote_list_bloc.dart';

class QuotePagedGridView extends StatelessWidget {
  static const _gridColumnCount = 2;

  const QuotePagedGridView({
    required this.pagingController,
    this.onQuoteSelected,
    super.key,
  });

  final PagingController<int, Quote> pagingController;
  final QuoteSelected? onQuoteSelected;

  @override
  Widget build(BuildContext context) {
    final theme = CuteTheme.of(context);
    final onQuoteSelected = this.onQuoteSelected;
    final bloc = context.read<QuoteListBloc>();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.screenMargin,
      ),
      child: PagedMasonryGridView.count(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Quote>(
          itemBuilder: (context, quote, index) {
            final isFavorite = quote.isFavorite ?? false;
            return QuoteCard(
              statement: quote.body,
              author: quote.author,
              isFavorite: isFavorite,
              top: const OpeningQuoteSvgAsset(),
              bottom: const ClosingQuoteSvgAsset(),
              onFavorite: () => bloc.add(
                isFavorite
                    ? QuoteListItemUnfavorited(quote.id)
                    : QuoteListItemFavorited(quote.id),
              ),
              onTap: onQuoteSelected != null
                  ? () async {
                      final updatedQuote = await onQuoteSelected(quote.id);

                      if (updatedQuote != null &&
                          updatedQuote.isFavorite != quote.isFavorite) {
                        bloc.add(
                          QuoteListItemUpdated(updatedQuote),
                        );
                      }
                    }
                  : null,
            );
          },
          firstPageErrorIndicatorBuilder: (context) {
            return ExceptionIndicator(
              onTryAgain: () => bloc.add(
                const QuoteListFailedFetchRetried(),
              ),
            );
          },
        ),
        crossAxisCount: _gridColumnCount,
        crossAxisSpacing: theme.gridSpacing,
        mainAxisSpacing: theme.gridSpacing,
      ),
    );
  }
}
