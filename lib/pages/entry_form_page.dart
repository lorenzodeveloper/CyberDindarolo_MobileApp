import 'package:cyberdindaroloapp/blocs/paginated/paginated_entries_bloc.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../bloc_provider.dart';
import '../validators.dart';

/*
* This class is the one responsible for entering products in piggybanks
* */

class EntryFormPage extends StatefulWidget {
  final PiggyBankModel piggyBankInstance;
  final ProductModel productInstance;

  final Function() onFormSuccessfullyValidated;
  final Function() onFormCancel;

  const EntryFormPage(
      {Key key,
      @required this.piggyBankInstance,
      @required this.productInstance,
      this.onFormSuccessfullyValidated,
      this.onFormCancel})
      : super(key: key);

  @override
  _EntryFormPageState createState() {
    return _EntryFormPageState();
  }
}

class _EntryFormPageState extends State<EntryFormPage> {
  // Form fields
  final _formKey = GlobalKey<FormState>();
  TextEditingController _quantityFieldController;
  TextEditingController _setPriceController;

  // Blocs
  PaginatedEntriesBloc _paginatedEntriesBloc;

  //PaginatedProductsBloc _paginatedProductsBloc;

  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  final _amountValidator2Digits =
      RegExInputFormatter.withRegex('^[0-9]{0,6}(\\.[0-9]{0,2})?\$');

  @override
  void initState() {
    _paginatedEntriesBloc = BlocProvider.of<PaginatedEntriesBloc>(context);
    //_paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);

    _quantityFieldController = TextEditingController();
    _setPriceController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Widget _getProductInfoHeader() {
    // Display product info in header fo widget
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                child: CircleAvatar(
                  minRadius: 15,
                  maxRadius: 30,
                  child: Icon(
                    Icons.category,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExpandablePanel(
                header: Text(
                  widget.productInstance.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                collapsed: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                  child: Text(
                    '${widget.productInstance.getDescription()} - ${widget.productInstance.pieces} per set.',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black45),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                  child: Text(
                      '${widget.productInstance.getDescription()} - ${widget.productInstance.pieces} per set.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black45)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert product in piggybank'),
      ),
      drawer: DefaultDrawer(),
      body: ListView(
        children: <Widget>[
          _getProductInfoHeader(),
          Divider(),
          ListTile(
              title: Text(
                'Please insert here product SET quantity and SINGLE set price.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Final product price will be: Set quantity * Single set price',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              )),
          Divider(),
          Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    // PB Name field
                    TextFormField(
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Enter Product\'s set quantity (e.g. 2)'),
                      controller: _quantityFieldController,
                      validator: (value) => gpStringValidator(value, 6)
                    ),

                    // PB Description field
                    TextFormField(
                      inputFormatters: [_amountValidator2Digits],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: InputDecoration(
                          labelText:
                              'Enter single product\'s set price (e.g. 5.99)'),
                      controller: _setPriceController,
                      validator: (value) => gpStringValidator(value, 6),
                    ),

                    // Save button
                    RaisedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState.validate()) {
                          final response =
                              await _paginatedEntriesBloc.insertEntry(
                            piggybank_id: widget.piggyBankInstance.id,
                            product_id: widget.productInstance.id,
                            set_quantity:
                                int.parse(_quantityFieldController.text),
                            single_set_price:
                                Decimal.parse(_setPriceController.text),
                          );

                          switch (response.status) {
                            case Status.LOADING:
                              // impossible
                              break;
                            case Status.COMPLETED:
                              if (widget.onFormSuccessfullyValidated != null)
                                widget.onFormSuccessfullyValidated();
                              Navigator.of(context).pop();

                              break;
                            case Status.ERROR:
                              if (response.message
                                  .toLowerCase()
                                  .contains('token')) {
                                showAlertDialog(
                                    context, 'Error', response.message,
                                    redirectRoute: '/');
                              } else {
                                showAlertDialog(
                                    context, 'Error', response.message);
                              }
                              break;
                          }
                        }
                      },
                      child: Text('Insert'),
                    ),

                    // Cancel button
                    RaisedButton(
                      onPressed: () async {
                        if (widget.onFormCancel != null) widget.onFormCancel();
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ]))),
        ],
      ),
    );
  }
}

class RegExInputFormatter implements TextInputFormatter {
  final RegExp _regExp;

  RegExInputFormatter._(this._regExp);

  factory RegExInputFormatter.withRegex(String regexString) {
    try {
      final regex = RegExp(regexString);
      return RegExInputFormatter._(regex);
    } catch (e) {
      // Something not right with regex string.
      assert(false, e.toString());
      return null;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldValueValid = _isValid(oldValue.text);
    final newValueValid = _isValid(newValue.text);
    if (oldValueValid && !newValueValid) {
      return oldValue;
    }
    return newValue;
  }

  bool _isValid(String value) {
    try {
      final matches = _regExp.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}
