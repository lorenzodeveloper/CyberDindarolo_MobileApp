import 'package:cyberdindaroloapp/blocs/paginated_entries_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../validators.dart';

class EntryFormPage extends StatefulWidget {
  final PiggyBankModel piggyBankInstance;
  final int productID;

  //final Function() onFormSuccessfullyValidated;
  //final Function() onFormCancel;

  const EntryFormPage({Key key,
    @required this.piggyBankInstance, @required this.productID,
    //@required this.onFormSuccessfullyValidated,
    //@required this.onFormCancel
  })
      : super(key: key);

  @override
  _EntryFormPageState createState() {
    return _EntryFormPageState();
  }
}

class _EntryFormPageState extends State<EntryFormPage> {
  // Form fields
  final _formKey = GlobalKey<FormState>();
  TextEditingController _pbNameController;
  TextEditingController _pbDescriptionController;

  PaginatedEntriesBloc _paginatedEntriesBloc;
  PaginatedProductsBloc _paginatedProductsBloc;

  ProductModel productInstance;

  @override
  void initState() {
    _paginatedEntriesBloc = new PaginatedEntriesBloc();
    _paginatedProductsBloc = new PaginatedProductsBloc();

    _pbNameController =
        TextEditingController(text: widget.piggyBankInstance.pbName);
    _pbDescriptionController =
        TextEditingController(text: widget.piggyBankInstance.pbDescription);



    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pbNameController.dispose();
    _pbDescriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert product in piggybank'),
      ),
      drawer: DefaultDrawer(),
      body: Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(children: <Widget>[
                // PB Name field
                TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: gpStringValidator,
                  decoration:
                  InputDecoration(labelText: 'Enter PiggyBank\'s name'),
                  controller: _pbNameController,
                ),

                // PB Description field
                TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: gpEmptyStringValidator,
                  decoration: InputDecoration(
                      labelText: 'Enter PiggyBank\'s description'),
                  controller: _pbDescriptionController,
                ),

                // Save button
                RaisedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState.validate()) {
                      /*final response = await _piggyBankBloc.updatePiggyBank(
                          id: widget.piggyBankInstance.id,
                          newName: _pbNameController.text,
                          newDescription: _pbDescriptionController.text);

                      switch (response.status) {
                        case Status.LOADING:
                          break;
                        case Status.COMPLETED:
                          widget.onFormSuccessfullyValidated();
                          break;
                        case Status.ERROR:
                          if (response.message.toLowerCase().contains('token')) {
                            showAlertDialog(context, 'Error', response.message,
                                redirectRoute: '/');
                          } else {
                            showAlertDialog(context, 'Error', response.message);
                          }
                          break;
                      }*/
                    }
                  },
                  child: Text('Save PiggyBank'),
                ),

                // Cancel button
                RaisedButton(
                  onPressed: () async {
                    //widget.onFormCancel();
                  },
                  child: Text('Cancel'),
                ),
              ]))),
    );
  }
}
