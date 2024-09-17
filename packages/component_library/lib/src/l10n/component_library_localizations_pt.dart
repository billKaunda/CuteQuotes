import 'component_library_localizations.dart';

/// The translations for Portuguese (`pt`).
class ComponentLibraryLocalizationsPt extends ComponentLibraryLocalizations {
  // ignore: use_super_parameters
  ComponentLibraryLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get downvoteIconButtonTooltip => 'Negativo';

  @override
  String get upvoteIconButtonTooltip => 'Positivo';

  @override
  String get searchBarHintText => 'jornada';

  @override
  String get searchBarLabelText => 'Pesquisar';

  @override
  String get shareIconButtonTooltip => 'Compartilhar';

  @override
  String get favoriteIconButtonTooltip => 'Favoritar';

  @override
  String get exceptionIndicatorGenericTitle => 'Algo deu errado';

  @override
  String get exceptionIndicatorTryAgainButton => 'Tentar Novamente';

  @override
  String get exceptionIndicatorGenericMessage => 'Ocorreu um erro.\nPor favor, confira sua conexão com a internet e tente novamente mais tarde.';

  @override
  String get genericErrorSnackBarMessage => 'An error occured. Please, check you internet connection.';

  @override
  String get authenticationRequiredErrorSnackBarMessage => 'To perform this action, kindly sign in.';
}
