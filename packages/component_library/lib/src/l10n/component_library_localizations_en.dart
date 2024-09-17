import 'component_library_localizations.dart';

/// The translations for English (`en`).
class ComponentLibraryLocalizationsEn extends ComponentLibraryLocalizations {
  // ignore: use_super_parameters
  ComponentLibraryLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get downvoteIconButtonTooltip => 'Downvote';

  @override
  String get upvoteIconButtonTooltip => 'Upvote';

  @override
  String get searchBarHintText => 'journey';

  @override
  String get searchBarLabelText => 'Search';

  @override
  String get shareIconButtonTooltip => 'Share';

  @override
  String get favoriteIconButtonTooltip => 'Favorite';

  @override
  String get exceptionIndicatorGenericTitle => 'Sorry, something went wrong';

  @override
  String get exceptionIndicatorTryAgainButton => 'Try Again';

  @override
  String get exceptionIndicatorGenericMessage => 'There has been an error.\nPlease, check your internet connection and then try again.';

  @override
  String get genericErrorSnackBarMessage => 'An error occured. Please, check you internet connection.';

  @override
  String get authenticationRequiredErrorSnackBarMessage => 'To perform this action, kindly sign in.';
}
