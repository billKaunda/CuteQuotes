import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './quote_list_bloc.dart';
import '../quote_list.dart';

const _itemSpacing = Spacing.xSmall;

class FilterHorizontalList extends StatelessWidget {
  const FilterHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.mediumLarge,
      ),
      child: Row(
        children: [
          const FavoritesChip(),
          ...Tag.values.map(
            (tag) => _TagChip(
              tag: tag,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesChip extends StatelessWidget {
  const FavoritesChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CuteTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        right: _itemSpacing,
        left: theme.screenMargin,
      ),
      child: BlocSelector<QuoteListBloc, QuoteListState, bool>(
        selector: (state) {
          final isFilteringByFavorites =
              state.filter is QuoteListFilterByFavorites;

          return isFilteringByFavorites;
        },
        builder: (context, isFavoritesOnly) {
          final l10n = QuoteListLocalizations.of(context);
          return RoundedChoiceChip(
            label: l10n.favoritesTagLabel,
            avatar: Icon(
              isFavoritesOnly ? Icons.favorite : Icons.favorite_border_outlined,
              color: isFavoritesOnly
                  ? theme.roundedChoiceChipSelectedAvatarColor
                  : theme.roundedChoiceChipAvatarColor,
            ),
            isSelected: isFavoritesOnly,
            onSelected: (isSelected) {
              _releaseFocus(context);
              final bloc = context.read<QuoteListBloc>();
              bloc.add(
                const QuoteListFilterByFavoritesToggled(),
              );
            },
          );
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    super.key,
  });

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final theme = CuteTheme.of(context);
    final isLastTag = Tag.values.last == tag;
    return Padding(
      padding: EdgeInsets.only(
        right: isLastTag ? theme.screenMargin : _itemSpacing,
        left: _itemSpacing,
      ),
      child: BlocSelector<QuoteListBloc, QuoteListState, Tag?>(
        selector: (state) {
          final filter = state.filter;
          final selectedTag =
              filter is QuoteListFilterByTag ? filter.tag : null;

          return selectedTag;
        },
        builder: (context, selectedTag) {
          final isSelected = selectedTag == tag;
          return RoundedChoiceChip(
            label: tag.toLocalizedString(context),
            isSelected: isSelected,
            onSelected: (isSelected) {
              _releaseFocus(context);
              final bloc = context.read<QuoteListBloc>();
              bloc.add(
                QuoteListTagChanged(
                  tag: isSelected ? tag : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _releaseFocus(BuildContext context) => FocusScope.of(context).unfocus();

extension on Tag {
  String toLocalizedString(BuildContext context) {
    final l10n = QuoteListLocalizations.of(context);
    switch (this) {
      case Tag.life:
        return l10n.lifeTagLabel;
      case Tag.happiness:
        return l10n.happinessTagLabel;
      case Tag.funny:
        return l10n.funnyTagLabel;
      case Tag.love:
        return l10n.loveTagLabel;
      case Tag.nature:
        return l10n.natureTagLabel;
      case Tag.science:
        return l10n.scienceTagLabel;
      case Tag.work:
        return l10n.workTagLabel;
    }
  }
}
