import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:quote_repository/quote_repository.dart';
import 'quote_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

typedef QuoteDetailsShareableLinkGenerator = Future<String> Function(
    Quote quote);

class QuoteDetailsScreen extends StatelessWidget {
  const QuoteDetailsScreen({
    super.key,
    required this.quoteId,
    required this.onAuthenticationError,
    required this.quoteRepository,
    this.shareableLinkGenerator,
  });

  final int quoteId;
  final VoidCallback onAuthenticationError;
  final QuoteRepository quoteRepository;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuoteDetailsCubit>(
      create: (_) => QuoteDetailsCubit(
        quoteId: quoteId,
        quoteRepository: quoteRepository,
      ),
      child: QuoteDetailsView(
        onAuthenticationError: onAuthenticationError,
        shareableLinkGenerator: shareableLinkGenerator,
      ),
    );
  }
}

@visibleForTesting
class QuoteDetailsView extends StatelessWidget {
  const QuoteDetailsView({
    super.key,
    required this.onAuthenticationError,
    this.shareableLinkGenerator,
  });

  final VoidCallback onAuthenticationError;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    return StyledStatusBar.dark(
      child: BlocConsumer<QuoteDetailsCubit, QuoteDetailsState>(
        listener: (context, state) {
          final quoteUpdateError =
              state is QuoteDetailsSuccess ? state.quoteUpdateError : null;
          if (quoteUpdateError != null) {
            final snackBar =
                quoteUpdateError is UserAuthenticationRequiredException
                    ? const AuthenticationRequiredErrorSnackBar()
                    : const GenericErrorSnackBar();

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);

            if (quoteUpdateError is UserAuthenticationRequiredException) {
              onAuthenticationError();
            }
          }
        },
        builder: (context, state) {
          return PopScope(
            onPopInvoked: (_) {
              final displayedQuote =
                  state is QuoteDetailsSuccess ? state.quote : null;
              return Navigator.of(context).pop(displayedQuote);
            },
            canPop: false,
            child: Scaffold(
              appBar: state is QuoteDetailsSuccess
                  ? _QuoteActionsAppBar(
                      quote: state.quote,
                      shareableLinkGenerator: shareableLinkGenerator,
                    )
                  : null,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(
                    CuteTheme.of(context).screenMargin,
                  ),
                  child: state is QuoteDetailsSuccess
                      ? _Quote(
                          quote: state.quote,
                        )
                      : state is QuoteDetailsFailure
                          ? ExceptionIndicator(
                              onTryAgain: () {
                                final cubit = context.read<QuoteDetailsCubit>();
                                cubit.refetch();
                              },
                            )
                          : const CenteredCircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuoteActionsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _QuoteActionsAppBar({
    super.key,
    required this.quote,
    this.shareableLinkGenerator,
  });

  final Quote quote;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuoteDetailsCubit>();
    final shareableLinkGenerator = this.shareableLinkGenerator;

    return RowAppBar(
      children: [
        FavoriteIconButton(
          isFavorite: quote.isFavorite ?? false,
          onTap: () {
            if (quote.isFavorite == true) {
              cubit.unfavoriteQuote();
            } else {
              cubit.favoriteQuote();
            }
          },
        ),
        UpvoteIconButton(
          count: quote.upvotesCount,
          isUpvoted: quote.isUpvoted ?? false,
          onTap: () {
            if (quote.isUpvoted == true) {
              cubit.unvoteQuote();
            } else {
              cubit.upvoteQuote();
            }
          },
        ),
        DownvoteIconButton(
          count: quote.downvotesCount,
          isDownvoted: quote.isDownvoted ?? false,
          onTap: () {
            if (quote.isDownvoted == true) {
              cubit.unvoteQuote();
            } else {
              cubit.downvoteQuote();
            }
          },
        ),
        if (shareableLinkGenerator != null)
          ShareIconButton(
            onTap: () async {
              final url = await shareableLinkGenerator(quote);
              Share.share(url);
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Quote extends StatelessWidget {
  static const double _quoteIconWidth = 46.0;

  const _Quote({
    super.key,
    required this.quote,
  });

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = CuteTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: OpeningQuoteSvgAsset(
            width: _quoteIconWidth,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xxLarge,
            ),
            child: Center(
              child: ShrinkableText(
                quote.body,
                style: theme.quoteTextStyle.copyWith(
                  fontSize: FontSize.xxlarge,
                ),
              ),
            ),
          ),
        ),
        const ClosingQuoteSvgAsset(
          width: _quoteIconWidth,
        ),
        const SizedBox(
          height: Spacing.medium,
        ),
        Text(
          quote.author ?? '',
          style: const TextStyle(
            fontSize: FontSize.large,
          ),
        )
      ],
    );
  }
}
