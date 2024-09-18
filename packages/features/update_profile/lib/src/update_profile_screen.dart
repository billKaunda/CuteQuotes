import 'package:component_library/component_library.dart';
import 'package:user_repository/user_repository.dart';
import 'package:form_fields/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './l10n/update_profile_localizations.dart';
import 'update_profile_cubit.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({
    required this.userRepository,
    required this.onUpdateProfileSuccess,
    super.key,
  });

  final UserRepository userRepository;
  final VoidCallback onUpdateProfileSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateProfileCubit>(
      create: (_) => UpdateProfileCubit(
        userRepository: userRepository,
      ),
      child: UpdateProfileView(
        onUpdateProfileSuccess: onUpdateProfileSuccess,
      ),
    );
  }
}

class UpdateProfileView extends StatelessWidget {
  const UpdateProfileView({
    required this.onUpdateProfileSuccess,
    super.key,
  });

  final VoidCallback onUpdateProfileSuccess;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _releaseFocus(context),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            UpdateProfileLocalizations.of(context).appBarTitle,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: Spacing.mediumLarge,
            left: Spacing.mediumLarge,
            right: Spacing.mediumLarge,
          ),
          child: _UpdateProfileForm(
            onUpdateProfileSuccess: onUpdateProfileSuccess,
          ),
        ),
      ),
    );
  }

  void _releaseFocus(BuildContext context) => FocusScope.of(context).unfocus();
}

class _UpdateProfileForm extends StatefulWidget {
  const _UpdateProfileForm({
    required this.onUpdateProfileSuccess,
    super.key,
  });

  final VoidCallback onUpdateProfileSuccess;

  @override
  State<_UpdateProfileForm> createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<_UpdateProfileForm> {
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus) {
        final cubit = context.read<UpdateProfileCubit>();
        cubit.onUsernameUnfocused();
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        final cubit = context.read<UpdateProfileCubit>();
        cubit.onEmailUnfocused();
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        final cubit = context.read<UpdateProfileCubit>();
        cubit.onPasswordUnfocused();
      }
    });

    _passwordConfirmationFocusNode.addListener(() {
      if (!_passwordConfirmationFocusNode.hasFocus) {
        final cubit = context.read<UpdateProfileCubit>();
        cubit.onPasswordConfirmationUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
      listenWhen: (oldState, newState) =>
          (oldState is UpdateProfileLoaded
              ? oldState.submissionStatus
              : null) !=
          (newState is UpdateProfileLoaded ? newState.submissionStatus : null),
      listener: (context, state) {
        if (state is UpdateProfileLoaded) {
          if (state.submissionStatus == SubmissionStatus.success) {
            widget.onUpdateProfileSuccess();
          }

          if (state.submissionStatus == SubmissionStatus.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const GenericErrorSnackBar(),
              );
          }
        }
      },
      builder: (context, state) {
        final l10n = UpdateProfileLocalizations.of(context);
        if (state is UpdateProfileLoaded) {
          final usernameError =
              state.username.isNotValid ? state.username.error : null;
          final emailError = state.email.isNotValid ? state.email.error : null;
          final passwordError =
              state.password!.isNotValid ? state.password!.error : null;
          final passwordConfirmationError =
              state.passwordConfirmation!.isNotValid
                  ? state.passwordConfirmation!.error
                  : null;
          final isSubmissionInProgress =
              state.submissionStatus == SubmissionStatus.inProgress;
          final cubit = context.read<UpdateProfileCubit>();
          return Column(
            children: <Widget>[
              TextFormField(
                focusNode: _usernameFocusNode,
                initialValue: state.username.value,
                onChanged: cubit.onUsernameChanged,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.person,
                  ),
                  enabled: !isSubmissionInProgress,
                  labelText: l10n.usernameTextFieldLabel,
                  errorText: usernameError == null
                      ? null
                      : (usernameError == UsernameValidationError.empty
                          ? l10n.usernameTextFieldEmptyErrorMessage
                          : (usernameError ==
                                  UsernameValidationError.isAlreadyTaken
                              ? l10n.usernameTextFieldAlreadyTakenErrorMessage
                              : l10n.usernameTextFieldInvalidErrorMessage)),
                ),
              ),
              const SizedBox(
                height: Spacing.mediumLarge,
              ),
              TextFormField(
                focusNode: _emailFocusNode,
                initialValue: state.email.value,
                onChanged: cubit.onEmailChanged,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.alternate_email,
                  ),
                  enabled: !isSubmissionInProgress,
                  labelText: l10n.emailTextFieldLabel,
                  errorText: emailError == null
                      ? null
                      : (emailError == EmailValidationError.empty
                          ? l10n.emailTextFieldEmptyErrorMessage
                          : (emailError ==
                                  EmailValidationError.alreadyRegistered
                              ? l10n.emailTextFieldAlreadyRegisteredErrorMessage
                              : l10n.emailTextFieldInvalidErrorMessage)),
                ),
              ),
              const SizedBox(
                height: Spacing.mediumLarge,
              ),
              TextFormField(
                focusNode: _passwordFocusNode,
                onChanged: cubit.onPasswordChanged,
                textInputAction: TextInputAction.next,
                obscureText: true,
                decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.password,
                    ),
                    enabled: !isSubmissionInProgress,
                    labelText: l10n.passwordTextFieldLabel,
                    errorText: passwordError == null
                        ? null
                        : l10n.passwordTextFieldInvalidErrorMessage),
              ),
              const SizedBox(
                height: Spacing.mediumLarge,
              ),
              TextFormField(
                focusNode: _passwordConfirmationFocusNode,
                onChanged: cubit.onPasswordConfirmationChanged,
                onEditingComplete: cubit.onSubmit,
                obscureText: true,
                decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.password,
                    ),
                    enabled: !isSubmissionInProgress,
                    labelText: l10n.passwordConfirmationTextFieldLabel,
                    errorText: passwordConfirmationError == null
                        ? null
                        : l10n
                            .passwordConfirmationTextFieldInvalidErrorMessage),
              ),
              const SizedBox(
                height: Spacing.xxxLarge,
              ),
              isSubmissionInProgress
                  ? ExpandedElevatedButton.inProgress(
                      label: l10n.updateProfileButtonLabel,
                    )
                  : ExpandedElevatedButton(
                      onTap: cubit.onSubmit,
                      label: l10n.updateProfileButtonLabel,
                      icon: const Icon(
                        Icons.login,
                      ),
                    ),
            ],
          );
        } else {
          return const CenteredCircularProgressIndicator();
        }
      },
    );
  }
}
