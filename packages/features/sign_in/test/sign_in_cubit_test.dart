import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:sign_in/src/sign_in_cubit.dart';
import 'package:form_fields/form_fields.dart';
import 'package:user_repository/user_repository.dart';

//Create a mock (class that implements UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('Sign In Cubit Test:', () {
    blocTest<SignInCubit, SignInState>(
      'Emits SignInState with unvalidated email when email is changed for '
      'the first time',
      build: () => SignInCubit(userRepository: MockUserRepository()),
      //Act on the cubit. This is what happens when the user enters the
      // email address in the text field.
      act: (cubit) => cubit.onEmailChanged('email@email.com'),
      //Evaluate the new state and compare it with your expected result
      expect: () => const <SignInState>[
        SignInState(
          email: Email.unvalidated(
            'email@email.com',
          ),
        ),
      ],
    );
  });
}
