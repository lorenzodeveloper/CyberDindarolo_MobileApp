import 'dart:async';

import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/home_page.dart';
import 'package:cyberdindaroloapp/pages/signup_page.dart';
import 'package:cyberdindaroloapp/validators.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class LoginPage extends StatelessWidget {
  final bool autoLogin;

  LoginPage({this.autoLogin: true});

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

  LoginForm({this.autoLogin: true});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _unameController;
  TextEditingController _pwdController;

  UserSessionBloc _userSessionbloc;
  StreamSubscription _userSessionStreamSubscription;

  @override
  void initState() {
    _userSessionbloc = BlocProvider.of<UserSessionBloc>(context);

    _unameController = TextEditingController(); //text: "lorenzo_lamas123");
    _pwdController = TextEditingController(); //text: "prova1234");

    _listen();

    // Try login with stored credential (if stored)
    if (widget.autoLogin) {
      _userSessionbloc.login();
    }

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _unameController.dispose();
    _pwdController.dispose();
    _userSessionStreamSubscription.cancel();
    super.dispose();
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
              MaterialPageRoute(builder: (context) => HomePage()));
          //Navigator.of(context).pushReplacementNamed('/home');
          break;
        case Status.ERROR:
          if (data.message != "Exception: Credentials not stored") {
            showAlertDialog(context, "Error", data.message);
          }
          break;
      }
    });
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
                validator: (value) => usernameValidator(value, 30),
                decoration: InputDecoration(labelText: 'Enter your username'),
                controller: _unameController,
              ),
              // Pwd field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) => passwordValidator(value, 8, 30),
                decoration: InputDecoration(labelText: 'Enter your password'),
                obscureText: true,
                controller: _pwdController,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    GestureDetector(
                        child: Text('Forgot your password?',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () {
//                          Navigator.of(context).push(MaterialPageRoute(
//                              builder: (context) => ForgotPassword()));
                        }),
                    GestureDetector(
                        child: Text('Sign-up',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                        })
                  ],
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    _userSessionbloc.login(
                        username: _unameController.text,
                        password: _pwdController.text);
                  }
                },
                child: Text('Login'),
              ),
            ])));
  }
}
