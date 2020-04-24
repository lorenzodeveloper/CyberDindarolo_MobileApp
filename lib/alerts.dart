import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/validators.dart';
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
        Navigator.of(context).popUntil((route) => route.isFirst);
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

Future<int> showQuantityInputDialog(BuildContext context,
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
                labelText: 'Quantity (min $min, max $max)',
                hintText: 'e.g. 1',
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

Future<String> showStringInputDialog(BuildContext context,
    {@required String title,
    @required String labelText,
    @required String hintText,
    @required int maxLength,
    bool empty: false}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return StringInputDialog(
        title: title,
        labelText: labelText,
        hintText: hintText,
        maxLength: maxLength,
        empty: empty,
      );
    },
  );
}

enum ThreeConfirmAction { CANCEL, ACCEPT, DECLINE }

Future<ThreeConfirmAction> asyncThreeConfirmDialog(BuildContext context,
    {@required String title,
    @required String question_message,
    String redirectRoute}) async {
  return showDialog<ThreeConfirmAction>(
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
                Navigator.of(context).pop(ThreeConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('ACCEPT'),
              onPressed: () {
                //onConfirmation();
                Navigator.of(context).pop(ThreeConfirmAction.ACCEPT);
                if (redirectRoute != null) {
                  Navigator.of(context).pushReplacementNamed(redirectRoute);
                }
              },
            ),
            FlatButton(
              child: const Text('DECLINE'),
              onPressed: () {
                //onConfirmation();
                Navigator.of(context).pop(ThreeConfirmAction.DECLINE);
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

class StringInputDialog extends StatefulWidget {
  final String title;
  final String labelText;
  final String hintText;
  final int maxLength;
  final bool empty;

  const StringInputDialog({
    Key key,
    @required this.title,
    @required this.labelText,
    @required this.hintText,
    @required this.maxLength,
    this.empty: false,
  }) : super(key: key);

  @override
  _StringInputDialogState createState() {
    return _StringInputDialogState();
  }
}

class _StringInputDialogState extends State<StringInputDialog> {
  String choice = '';

  final _formKey = GlobalKey<FormState>();
  TextEditingController _fieldController;

  @override
  void initState() {
    if (widget.maxLength < 0 && widget.empty ||
        widget.maxLength <= 0 && !widget.empty)
      throw Exception('maxLength must be a non negative number');
    _fieldController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: new Row(
        children: <Widget>[
          Expanded(
            child: Form(
                key: _formKey,
                child: new TextFormField(
                  controller: _fieldController,
                  validator: widget.empty
                      ? (value) =>
                          gpEmptyStringValidator(value, widget.maxLength)
                      : (value) => gpStringValidator(value, widget.maxLength),
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                  ),
                )),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Navigator.of(context).pop(_fieldController.text);
            }
          },
        ),
      ],
    );
  }
}

Future<Response<ProductModel>> showProductOptionDialog(
    BuildContext context) async {
  // This method create a dynamic Product Dialog -> returns null if new product
  // is selected, productInstance otherwise

  return await showDialog<Response<ProductModel>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProductsDialog();
      });
}
