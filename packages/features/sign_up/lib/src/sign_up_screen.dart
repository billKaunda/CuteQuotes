import 'package:component_library/component_library.dart';
import 'package:user_repository/user_repository.dart';
import 'package:form_fields/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './l10n/sign_up_localizations.dart';
import 'sign_up_cubit.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({
    required this.userRepository,
    required this.onSignUpSuccess,
    Key? key,
  }) : super(key: key);

  final UserRepository userRepository;
  final VoidCallback onSignUpSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (_) => SignUpCubit(
        userRepository: userRepository,
      ),
      child: SignUpView(
        onSignUpSuccess: onSignUpSuccess,
      ),
    );
  }
}

@visibleForTesting
class SignUpView extends StatelessWidget {
  const SignUpView({
    required this.onSignUpSuccess,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSignUpSuccess;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            SignUpLocalizations.of(context).appBarTitle,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: Spacing.mediumLarge,
            left: Spacing.mediumLarge,
            right: Spacing.mediumLarge,
          ),
          child: _SignUpForm(
            onSignUpSuccess: onSignUpSuccess,
          ),
        ),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({
    required this.onSignUpSuccess,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSignUpSuccess;
  @override
  State<_SignUpForm> createState() => __SignUpFormState();
}

class __SignUpFormState extends State<_SignUpForm> {
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setUpEmailFieldFocusListener();
    _setUpUsernameFieldFocusListener();
    _setUpPasswordFieldFocusListener();
    _setUpPasswordConfirmationFieldFocusListener();
  }

  void _setUpEmailFieldFocusListener() {
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        final cubit = context.read<SignUpCubit>();
        cubit.onEmailUnfocused();
      }
    });
  }

  void _setUpUsernameFieldFocusListener() {
    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus) {
        final cubit = context.read<SignUpCubit>();
        cubit.onUsernameUnfocused();
      }
    });
  }

  void _setUpPasswordFieldFocusListener() {
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        final cubit = context.read<SignUpCubit>();
        cubit.onPasswordUnfocused();
      }
    });
  }

  void _setUpPasswordConfirmationFieldFocusListener() {
    _passwordConfirmationFocusNode.addListener(() {
      if (!_passwordConfirmationFocusNode.hasFocus) {
        final cubit = context.read<SignUpCubit>();
        cubit.onPasswordConfirmationUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          widget.onSignUpSuccess;
        }

        if (state.submissionStatus == SubmissionStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const GenericErrorSnackBar(),
            );
        }
      },
      builder: (context, state) {
        final l10n = SignUpLocalizations.of(context);
        final cubit = context.read<SignUpCubit>();
        final usernameError =
            state.username!.isNotValid ? state.username!.error : null;
        final emailError = state.email!.isNotValid ? state.email!.error : null;
        final passwordError =
            state.password!.isNotValid ? state.password!.error : null;
        final passwordConfirmationError = state.passwordConfirmation!.isNotValid
            ? state.passwordConfirmation!.error
            : null;
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;
        return Column(
          children: <Widget>[
            TextField(
              focusNode: _emailFocusNode,
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
                        : (emailError == EmailValidationError.alreadyRegistered
                            ? l10n.emailTextFieldAlreadyRegisteredErrorMessage
                            : l10n.emailTextFieldInvalidErrorMessage)),
              ),
            ),
            const SizedBox(
              height: Spacing.mediumLarge,
            ),
            TextField(
              focusNode: _usernameFocusNode,
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
            TextField(
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
                    : (passwordError == PasswordValidationError.empty
                        ? l10n.passwordTextFieldEmptyErrorMessage
                        : l10n.passwordTextFieldInvalidErrorMessage),
              ),
            ),
            const SizedBox(
              height: Spacing.mediumLarge,
            ),
            TextField(
              focusNode: _passwordConfirmationFocusNode,
              onChanged: cubit.onPasswordConfirmationChanged,
              obscureText: true,
              onEditingComplete: cubit.onSubmit,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.password,
                ),
                enabled: !isSubmissionInProgress,
                labelText: l10n.passwordConfirmationTextFieldLabel,
                errorText: passwordConfirmationError == null
                    ? null
                    : (passwordConfirmationError ==
                            PasswordConfirmationValidationError.empty
                        ? l10n.passwordConfirmationTextFieldEmptyErrorMessage
                        : l10n
                            .passwordConfirmationTextFieldInvalidErrorMessage),
              ),
            ),
            const SizedBox(
              height: Spacing.xxLarge,
            ),
            isSubmissionInProgress
                ? ExpandedElevatedButton.inProgress(
                    label: l10n.signUpButtonLabel,
                  )
                : ExpandedElevatedButton(
                    onTap: cubit.onSubmit,
                    label: l10n.signUpButtonLabel,
                    icon: const Icon(
                      Icons.login,
                    ),
                  ),
          ],
        );
      },
    );
  }
}
