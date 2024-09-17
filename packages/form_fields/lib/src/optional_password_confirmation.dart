import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import './optional_password.dart';

/*
Represents an optional password confirmation field

Used together with [OptionalPassword] when the password
can or can't be changed, e.g, in the update profile screen
*/

enum OptionalPasswordConfirmationValidationError { empty, invalid }

class OptionalPasswordConfirmation
    extends FormzInput<String, OptionalPasswordConfirmationValidationError>
    with EquatableMixin {
  const OptionalPasswordConfirmation.unvalidated([
    String value = '',
  ])  : password = const OptionalPassword.unvalidated(),
        super.pure(value);

  const OptionalPasswordConfirmation.validated(
    String value, {
    this.password,
  }) : super.dirty(value);

  final OptionalPassword? password;

  @override
  OptionalPasswordConfirmationValidationError? validator(String value) {
    return value.isEmpty
        ? (password!.value.isEmpty
            ? null
            : OptionalPasswordConfirmationValidationError.empty)
        : (value == password!.value
            ? null
            : OptionalPasswordConfirmationValidationError.invalid);
  }

  @override
  List<Object?> get props => [value, password];
}
