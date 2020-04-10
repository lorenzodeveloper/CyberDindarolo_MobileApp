import 'package:cyberdindaroloapp/blocs/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
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

  PaginatedProductsBloc paginatedProductsBloc = new PaginatedProductsBloc();
  paginatedProductsBloc.fetchProducts();

  return await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        int currentPage = 1;
        int nextPage = -1;
        int prevPage = -1;

        // stateful builder needed to update Next and Prev button
        return StatefulBuilder(
          builder: (context, setState) {
            return StreamBuilder<Response<PaginatedProductsModel>>(
                stream: paginatedProductsBloc.pagProductsListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.data != null) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return CircularProgressIndicator();
                        break;
                      case Status.COMPLETED:
                        // Next page and prevoius page setting..
                        if (snapshot.data.data.previous == null) {
                          prevPage = -1;
                        } else {
                          prevPage = currentPage - 1;
                        }

                        if (snapshot.data.data.next == null) {
                          nextPage = -1;
                        } else {
                          nextPage = currentPage + 1;
                        }

                        return SimpleDialog(
                          title: const Text('Select a Product'),
                          // Generate list of product
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    snapshot.data.data.results.length + 1,
                                itemBuilder: (context, index) {
                                  // First tile is reserved for 'add new product'
                                  if (index != 0) {
                                    ProductModel productInstance =
                                        snapshot.data.data.results[index - 1];
                                    return SimpleDialogOption(
                                      onPressed: () {
                                        paginatedProductsBloc.dispose();
                                        Navigator.pop(
                                            context, productInstance.id);
                                      },
                                      child: ListTile(
                                        title: Text(
                                          '${productInstance.name} '
                                          '(PG_ID: ${productInstance.validForPiggyBank})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          productInstance.getDescription(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SimpleDialogOption(
                                        onPressed: () {
                                          paginatedProductsBloc.dispose();
                                          Navigator.pop(context, -1);
                                        },
                                        child: ListTile(
                                            title: Text('Add new product'),
                                          leading: Icon(Icons.add),
                                        ));
                                  }
                                }),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                  child: Text('Prev'),
                                  onPressed: prevPage <= 0
                                      ? null
                                      : () {
                                          currentPage--;
                                          paginatedProductsBloc.fetchProducts(
                                              page: prevPage);
                                        },
                                ),
                                RaisedButton(
                                  child: Text('Next'),
                                  onPressed: nextPage <= 0
                                      ? null
                                      : () {
                                          currentPage++;
                                          paginatedProductsBloc.fetchProducts(
                                              page: nextPage);
                                        },
                                ),
                              ],
                            )
                          ],
                        );
                        break;
                      case Status.ERROR:
                        // TODO: HANDLE ERROR
                        break;
                    }
                  }
                  return Container();
                });
          },
        );
      });
}
