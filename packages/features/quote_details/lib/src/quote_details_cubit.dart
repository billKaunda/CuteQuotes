import 'package:domain_models/domain_models.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'quote_details_state.dart';

//To create a cubit, you have to extend Cubit and specify your base
// state class as the generic type.
class QuoteDetailsCubit extends Cubit<QuoteDetailsState> {
  QuoteDetailsCubit({
    required this.quoteId,
    required this.quoteRepository,
  }) : super(
          //You have to pass an instance of the initial state that
          // will be provided to the UI when the screen first opens
          const QuoteDetailsInProgress(),
        ) {
    _fetchQuoteDetails();
  }

  final int quoteId;
  final QuoteRepository quoteRepository;

  Future<void> _fetchQuoteDetails() async {
    try {
      final quote = await quoteRepository.getQuoteDetails(quoteId);
      emit(
        QuoteDetailsSuccess(quote: quote),
      );
    } catch (error) {
      emit(
        const QuoteDetailsFailure(),
      );
    }
  }

  //On tapping try again button, this function is called
  Future<void> refetch() async {
    emit(
      const QuoteDetailsInProgress(),
    );
    _fetchQuoteDetails();
  }

  void upvoteQuote() async {
    await _executeQuoteUpdateOperation(
      () => quoteRepository.upvoteQuote(quoteId),
    );
  }

  void downvoteQuote() async {
    await _executeQuoteUpdateOperation(
      () => quoteRepository.downvoteQuote(quoteId),
    );
  }

  void unvoteQuote() async {
    await _executeQuoteUpdateOperation(
      () => quoteRepository.unvoteQuote(quoteId),
    );
  }

  void favoriteQuote() async {
    await _executeQuoteUpdateOperation(
      () => quoteRepository.favoriteQuote(quoteId),
    );
  }

  void unfavoriteQuote() async {
    await _executeQuoteUpdateOperation(
      () => quoteRepository.unfavoriteQuote(
        quoteId,
      ),
    );
  }

  Future<void> _executeQuoteUpdateOperation(
    Future<Quote> Function() updateQuote,
  ) async {
    try {
      final updatedQuote = await updateQuote();
      emit(
        QuoteDetailsSuccess(quote: updatedQuote),
      );
    } catch (error) {
      final lastState = state;
      if (lastState is QuoteDetailsSuccess) {
        emit(
          QuoteDetailsSuccess(
            quote: lastState.quote,
            quoteUpdateError: error,
          ),
        );
      }
    }
  }
}
