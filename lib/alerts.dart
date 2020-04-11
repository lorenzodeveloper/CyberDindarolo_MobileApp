import 'package:cyberdindaroloapp/widgets/products_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(onWillPop: () async => false, child: alert);
    },
  );
}

/*showConfirmationDialog(BuildContext context,
    {@required String title,
    @required String question_message,
    @required void Function() onConfirmation,
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
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}*/

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> asyncConfirmDialog(BuildContext context,
    {@required String title,
    @required String question_message,
    //@required void Function() onConfirmation,
    String redirectRoute}) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title),
          content: Text(question_message),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('ACCEPT'),
              onPressed: () {
                //onConfirmation();
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
                if (redirectRoute != null) {
                  Navigator.of(context).pushReplacementNamed(redirectRoute);
                }
              },
            )
          ],
        ),
      );
    },
  );
}

Future<int> asyncInputDialog(BuildContext context,
    {@required String title,
    @required int min,
    @required int max,
    String message}) async {
  String choice = '';

  if (min > max || min < 0 || max < 0)
    throw Exception("Invalid min/max input.");

  //var valueList = new List<int>.generate(max - min + 1, (i) => i + 1);

  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: new InputDecoration(
                labelText: 'Quantity',
                hintText: 'eg. 1',
              ),
              onChanged: (value) {
                choice = value;
              },
            ))
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              if (choice != '') {
                int intChoice = int.parse(choice);
                if (intChoice >= min && intChoice <= max) {
                  Navigator.of(context).pop(intChoice);
                } else {
                  print("Not valid");
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<int> asyncProductOptionDialog(BuildContext context) async {
  // This method create a dynamic Product Dialog -> returns -1 if new product
  // is selected, product_id otherwise

  return await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProductsDialog();
      });
}
