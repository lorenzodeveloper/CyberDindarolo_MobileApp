library validators;

Function(String, int) usernameValidator = (String value, int maxLength) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }

  if (value.length > maxLength) return 'Max $maxLength chars';

  if (!value.contains(new RegExp(r'^[-a-zA-Z0-9_@.]+$'))) {
    return 'Invalid characters';
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


Function(String, int, int) passwordValidator = (String value, int minLength, int maxLength) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }
  if (value.length < minLength) return 'At least $minLength chars';
  if (value.length > maxLength) return 'Max $maxLength chars';

  return null;
};