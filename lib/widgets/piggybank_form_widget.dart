import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../validators.dart';

class PiggyBankForm extends StatefulWidget {
  final PiggyBankModel piggyBankInstance;
  final Function() onFormSuccessfullyValidated;
  final Function() onFormCancel;

  const PiggyBankForm({Key key,
    this.piggyBankInstance,
    @required this.onFormSuccessfullyValidated,
    @required this.onFormCancel})
      : super(key: key);

  @override
  _PiggyBankFormState createState() {
    return _PiggyBankFormState();
  }
}

class _PiggyBankFormState extends State<PiggyBankForm> {
  // Form fields
  final _formKey = GlobalKey<FormState>();
  TextEditingController _pbNameController;
  TextEditingController _pbDescriptionController;

  PiggyBankBloc _piggyBankBloc;

  @override
  void initState() {
    _piggyBankBloc = BlocProvider.of<PiggyBankBloc>(context);

    _pbNameController =
        TextEditingController(text: widget.piggyBankInstance?.pbName);
    _pbDescriptionController =
        TextEditingController(text: widget.piggyBankInstance?.pbDescription);

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
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              // PB Name field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) => gpStringValidator(value, 30),
                decoration:
                InputDecoration(labelText: 'Enter PiggyBank\'s name'),
                controller: _pbNameController,
              ),

              // PB Description field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) => gpEmptyStringValidator(value, 255),
                decoration: InputDecoration(
                    labelText: 'Enter PiggyBank\'s description'),
                controller: _pbDescriptionController,
              ),

              // Save button
              RaisedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    var response;
                    if (widget.piggyBankInstance != null) {
                      response = await _piggyBankBloc.updatePiggyBank(
                          id: widget.piggyBankInstance.id,
                          newName: _pbNameController.text,
                          newDescription: _pbDescriptionController.text);
                    } else {
                      response = await _piggyBankBloc.createPiggyBank(
                          name: _pbNameController.text,
                          description: _pbDescriptionController.text);
                    }

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
                    }
                  }
                },
                child: Text('Save PiggyBank'),
              ),

              // Cancel button
              RaisedButton(
                onPressed: () async {
                  widget.onFormCancel();
                },
                child: Text('Cancel'),
              ),
            ])));
  }
}
