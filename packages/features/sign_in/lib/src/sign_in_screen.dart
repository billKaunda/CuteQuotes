import 'package:component_library/component_library.dart';
import 'package:user_repository/user_repository.dart';
import 'package:form_fields/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './l10n/sign_in_localizations.dart';
import './sign_in_cubit.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    required this.userRepository,
    required this.onSignInSuccess,
    this.onForgotMyPasswordTap,
    this.onSignUpTap,
    Key? key,
  }) : super(key: key);

  final UserRepository userRepository;
  final VoidCallback onSignInSuccess;
  final VoidCallback? onForgotMyPasswordTap;
  final VoidCallback? onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(
        userRepository: userRepository,
      ),
      child: SignInView(
        onSignUpTap: onSignUpTap,
        onSignInSuccess: onSignInSuccess,
        onForgotMyPasswordTap: onForgotMyPasswordTap,
      ),
    );
  }
}

@visibleForTesting
class SignInView extends StatelessWidget {
  const SignInView({
    required this.onSignInSuccess,
    this.onSignUpTap,
    this.onForgotMyPasswordTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSignInSuccess;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotMyPasswordTap;

  @override
  Widget build(BuildContext context) {
    final l10n = SignInLocalizations.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(l10n.appBarTitle),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.mediumLarge,
            ),
            child: _SignInForm(
              onSignInSuccess: onSignInSuccess,
              onSignUpTap: onSignUpTap,
              onForgotMyPasswordTap: onForgotMyPasswordTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({
    required this.onSignInSuccess,
    this.onSignUpTap,
    this.onForgotMyPasswordTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSignInSuccess;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotMyPasswordTap;

  @override
  State<_SignInForm> createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  //Create focus nodes for email and password text fields
  //Focus node is an object attached to a TextField to listen
  // to and control a field's focus

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //Instantiate SignInCubit to call functions on it
    final cubit = context.read<SignInCubit>();

    //Add listeners to the declared FocusNodes. These listeners
    // run every time a field loses or gains focus. Since we're only
    // interested in knowing when the focus is lost, we use an if
    // statement to distinguish between the two events.
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        cubit.onEmailUnfocused();
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        cubit.onPasswordUnfocused();
      }
    });
  }

  //Dispose the focus nodes
  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SignInLocalizations.of(context);
    return BlocConsumer<SignInCubit, SignInState>(
      listenWhen: (previousState, currentState) =>
          previousState.submissionStatus != currentState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          widget.onSignInSuccess();
          return;
        }

        final hasSubmissionError = (state.submissionStatus ==
                SubmissionStatus.invalidCredentialsError ||
            state.submissionStatus == SubmissionStatus.genericError);

        if (hasSubmissionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              state.submissionStatus == SubmissionStatus.invalidCredentialsError
                  ? SnackBar(
                      content: Text(
                        l10n.invalidCredentialsErrorMessage,
                      ),
                    )
                  : const GenericErrorSnackBar(),
            );
        }
      },
      builder: (context, state) {
        //Check if the email's and password's field status is invalid, if yes,
        // grab the error type.
        final emailError = state.email.isNotValid ? state.email.error : null;
        final passwordError =
            state.password.isNotValid ? state.password.error : null;
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;

        final cubit = context.read<SignInCubit>();
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
                        : l10n.emailTextFieldInvalidErrorMessage),
              ),
            ),
            const SizedBox(height: Spacing.large),
            TextField(
              focusNode: _passwordFocusNode,
              onChanged: cubit.onPasswordChanged,
              obscureText: true,
              onEditingComplete: cubit.onSubmit,
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
            TextButton(
              onPressed:
                  isSubmissionInProgress ? null : widget.onForgotMyPasswordTap,
              child: Text(
                l10n.forgotMyPasswordButtonLabel,
              ),
            ),
            const SizedBox(height: Spacing.small),
            isSubmissionInProgress
                ? ExpandedElevatedButton.inProgress(
                    label: l10n.signInButtonLabel,
                  )
                : ExpandedElevatedButton(
                    label: l10n.signInButtonLabel,
                    onTap: cubit.onSubmit,
                    icon: const Icon(
                      Icons.login,
                    ),
                  ),
            const SizedBox(
              height: Spacing.xxLarge,
            ),
            Text(
              l10n.signUpOpeningText,
            ),
            TextButton(
              onPressed: isSubmissionInProgress ? null : widget.onSignUpTap,
              child: Text(
                l10n.signUpButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}
