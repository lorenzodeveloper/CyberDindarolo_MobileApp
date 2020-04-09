library validators;

Function(String) usernameValidator = (String value) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }
  if (!value.contains(new RegExp(r'^[-a-zA-Z0-9_@.]+$'))) {
    return 'Invalid characters';
  }
  if (value.length < 3) {
    return 'At least 3 chars';
  }
  return null;
};

Function(String) gpStringValidator = (String value) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }

  final alphanumeric = RegExp(r'^[-a-zA-Z0-9_@. ]+$');

  if (!alphanumeric.hasMatch(value)) {
    return 'Invalid characters';
  }
  return null;
};

Function(String) gpEmptyStringValidator = (String value) {
  final alphanumeric = RegExp(r'^[-a-zA-Z0-9_@. ]+$');

  if (!alphanumeric.hasMatch(value) && value.isNotEmpty) {
    return 'Invalid characters';
  }
  return null;
};


Function(String) passwordValidator = (String value) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }
  if (value.length < 8) return 'At least 8 chars';
  return null;
};