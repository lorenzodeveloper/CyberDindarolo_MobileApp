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

Function(String) passwordValidator = (String value) {
  if (value.isEmpty) {
    return 'Please enter some text';
  }
  if (value.length < 8) return 'At least 8 chars';
  return null;
};