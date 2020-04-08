import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String message,
    {String redirectRoute}) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      //Navigator.of(context).popAndPushNamed(redirectRoute);
      Navigator.of(context).pop();
      if (redirectRoute != null) {
        Navigator.of(context).pushReplacementNamed(redirectRoute);
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showConfirmationDialog(BuildContext context,
    {@required String title,
    @required String question_message, @required void Function() onConfirmation,
    String redirectRoute}) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("No"),
    onPressed: () {
      Navigator.of(context).pop();
      if (redirectRoute != null) {
        Navigator.of(context).pushReplacementNamed(redirectRoute);
      }
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Yes"),
    onPressed: () {
      onConfirmation();
      Navigator.of(context).pop();
      if (redirectRoute != null) {
        Navigator.of(context).pushReplacementNamed(redirectRoute);
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(question_message),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
