import 'package:equatable/equatable.dart';
import './quote.dart';

class QuoteListPage extends Equatable {
  const QuoteListPage({
    required this.isLastPage,
    required this.quoteList,
  });

  final bool isLastPage;
  final List<Quote> quoteList;

  @override
  List<Object> get props => [
        isLastPage,
        quoteList,
      ];
}
