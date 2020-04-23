import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/validators.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class UserForm extends StatefulWidget {
  final UserProfileModel userInstance;

  const UserForm({Key key, this.userInstance}) : super(key: key);

  @override
  _UserFormState createState() {
    return _UserFormState();
  }
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  UserSessionBloc _userSessionBloc;

  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _emailController;
  TextEditingController _pwdAController;
  TextEditingController _pwdBController;
  TextEditingController _usernameController;

  String _pwdErrorMessage;

  @override
  void initState() {
    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    _firstNameController =
        new TextEditingController(text: widget.userInstance?.first_name);
    _lastNameController =
        new TextEditingController(text: widget.userInstance?.last_name);
    _emailController =
        new TextEditingController(text: widget.userInstance?.email);

    _pwdAController = new TextEditingController();
    _pwdBController = new TextEditingController();

    _usernameController =
        new TextEditingController(text: widget.userInstance?.username);

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _pwdAController.dispose();
    _pwdBController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String _validatePasswords(String pwdA, String pwdB) {
    // Se è una registrazione o se è una modifica e una delle due pwd è compilata
    if (!isNullOrEmpty(pwdA) ||
        !isNullOrEmpty(pwdB) ||
        widget.userInstance == null) {
      if (pwdA != pwdB) return 'Passwords don\'t match';
      if (pwdA.length < 8 || pwdB.length < 8) return 'Password too short';
      if (pwdA.length > 255 || pwdB.length > 255) return 'Password too long';
    }
    return null;
  }

  bool isNullOrEmpty(String text) => text?.isEmpty ?? true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              enabled: widget.userInstance == null,
              decoration: InputDecoration(labelText: 'Username'),
              controller: _usernameController,
              validator: (value) => usernameValidator(value, 30),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'First Name'),
              controller: _firstNameController,
              validator: (value) => gpStringValidator(value, 30),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Last Name'),
              controller: _lastNameController,
              validator: (value) => gpStringValidator(value, 30),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              controller: _emailController,
              validator: (value) => gpStringValidator(value, 255),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'New Password', errorText: _pwdErrorMessage),
              controller: _pwdAController,
              obscureText: true,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  errorText: _pwdErrorMessage),
              controller: _pwdBController,
              obscureText: true,
            ),
            RaisedButton(
              onPressed: () async {
                // Custom validation because user can choose to not change password.
                setState(() {
                  _pwdErrorMessage = _validatePasswords(
                      _pwdAController?.text, _pwdBController?.text);
                });

                if (_formKey.currentState.validate() &&
                    _pwdErrorMessage == null) {
                  var newInstance;
                  var response;

                  if (widget.userInstance != null) {
                    newInstance = UserProfileModel(
                        auth_user_id: widget.userInstance.auth_user_id,
                        username: widget.userInstance.username,
                        email: _emailController.text,
                        first_name: _firstNameController.text,
                        last_name: _lastNameController.text);

                    response = await _userSessionBloc.editProfile(
                        oldInstance: widget.userInstance,
                        newInstance: newInstance,
                        newPwd: _pwdAController.text);
                  } else {
                    newInstance = UserProfileModel(
                        auth_user_id: -1,
                        username: _usernameController.text,
                        email: _emailController.text,
                        first_name: _firstNameController.text,
                        last_name: _lastNameController.text);
                    response = await _userSessionBloc.createUser(
                        instance: newInstance, pwd: _pwdAController.text);
                  }

                  switch (response?.status) {
                    case Status.LOADING:
                      // impossible
                      break;
                    case Status.COMPLETED:
                      //if (widget.onFormSuccessfullyValidated != null)
                      //widget.onFormSuccessfullyValidated();
                      String message =
                          'Edit successfully completed, you\'ll be redirected to login page';
                      if (widget.userInstance == null) {
                        message =
                            'Sign up completed! Please confirm your email before login.';
                        await showAlertDialog(context, 'Warning', message,
                            redirectRoute: '/');
                      } else {
                        _userSessionBloc.logout();
                        await showAlertDialog(context, 'Warning', message,
                            redirectRoute: '/');
                      }
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
              child: Text(widget.userInstance != null ? 'Save' : 'Sign-up'),
            )
          ],
        ),
      ),
    );
  }
}
