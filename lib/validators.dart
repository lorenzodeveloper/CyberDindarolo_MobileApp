library validators;

/*
* String validators
* */

Function(String, int) usernameValidator = (String value, int maxLength) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }

  if (value.length > maxLength) return 'Max $maxLength chars';

  final usernameRegEx = RegExp(r'^[-a-zA-Z0-9_@.]+$');

  if (!usernameRegEx.hasMatch(value)) {
    return 'Invalid characters';
  }
  if (value.length < 3) {
    return 'At least 3 chars';
  }
  return null;
};

Function(String) emailValidator = (String value) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }

  if (value.length > 255) return 'Max 255 chars';

  final emailRegEx =
      RegExp(r'^[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+.[-a-zA-Z0-9_@.]+$');

  if (!emailRegEx.hasMatch(value)) {
    return 'Invalid email.';
  }

  if (value.length < 3) {
    return 'At least 3 chars';
  }
  return null;
};

Function(String, int) gpStringValidator = (String value, int maxLength) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }

  if (value.length > maxLength) return 'Max $maxLength chars';

  final alphanumeric = RegExp(r'^[-a-zA-Z0-9_@. ]+$');

  if (!alphanumeric.hasMatch(value)) {
    return 'Invalid characters';
  }
  return null;
};

Function(String, int) gpEmptyStringValidator = (String value, int maxLength) {
  if (value.length > maxLength) return 'Max $maxLength chars';

  final alphanumeric = RegExp(r'^[-a-zA-Z0-9_@. ]+$');

  if (!alphanumeric.hasMatch(value) && value.isNotEmpty) {
    return 'Invalid characters';
  }
  return null;
};

Function(String, int, int) passwordValidator =
    (String value, int minLength, int maxLength) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }
  if (value.length < minLength) return 'At least $minLength chars';
  if (value.length > maxLength) return 'Max $maxLength chars';

  return null;
};
