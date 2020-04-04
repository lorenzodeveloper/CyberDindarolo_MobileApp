import 'dart:async';

import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/view/paginated_pbs_view.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class LoginPage extends StatelessWidget {
  final bool autoLogin;

  LoginPage({this.autoLogin : true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(autoLogin: autoLogin),
    );
  }
}

// Define a custom Form widget.
class LoginForm extends StatefulWidget {

  final bool autoLogin;

  LoginForm({this.autoLogin : true});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final unameController = TextEditingController(text: "lorenzo_lamas123");
  final pwdController = TextEditingController(text: "prova1234");

  UserSessionBloc _userSessionbloc;
  StreamSubscription _userSessionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _userSessionbloc = BlocProvider.of<UserSessionBloc>(context);
    _listen();
    // Try login with stored credential (if stored)
    if (widget.autoLogin) {
      _userSessionbloc.login();
    }
  }

  void _listen() {
    _userSessionStreamSubscription =
        _userSessionbloc.userListStream.listen((data) {
      switch (data.status) {
        case Status.LOADING:
          print("Loading...");
          break;
        case Status.COMPLETED:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PiggyBanksPage()));
          //Navigator.of(context).pushReplacementNamed('/home');
          break;
        case Status.ERROR:
          if (data.message != "Exception: Credentials not stored") {
            showAlertDialog(context, "Error", data.message);
          }
          //print("Error: " + data.message);
          break;
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unameController.dispose();
    pwdController.dispose();
    _userSessionStreamSubscription.cancel();
    //_userSessionbloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              // Username field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (!value.contains(new RegExp(r'^[-a-zA-Z0-9_@.]+$'))) {
                    return 'Invalid characters';
                  }
                  if (value.length < 3) return 'At least 3 chars';
                  return null;
                },
                decoration: InputDecoration(labelText: 'Enter your username'),
                controller: unameController,
              ),
              // Pwd field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length < 8) return 'At least 8 chars';
                  return null;
                },
                decoration: InputDecoration(labelText: 'Enter your password'),
                obscureText: true,
                controller: pwdController,
              ),

              RaisedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    _userSessionbloc.login(
                        username: unameController.text,
                        password: pwdController.text);
                  }
                },
                child: Text('Login'),
              ),
            ])));
  }
}
