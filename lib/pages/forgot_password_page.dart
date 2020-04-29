import 'package:cyberdindaroloapp/alerts.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/validators.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    Key key,
  }) : super(key: key);

  @override
  _ForgotPasswordPageState createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController;

  UserSessionBloc _userSessionBloc;

  @override
  void initState() {
    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    _emailController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Password reset',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      //backgroundColor: Color(0xFF333333),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                'Please, in order to reset your password, '
                'insert your email here and follow instructions.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  '\nYou will receive one email to verify that you have requested'
                  ' the password reset, and another email with a '
                  'temporary password to gain access to your account.'
                  '\nThe temp password will expire in 24 '
                  'hours and if you won\'t change it before the expiration '
                  'time, your account will be closed.'),
            ),
            Divider(),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      validator: (value) => emailValidator(value),
                      decoration: InputDecoration(
                          labelText: 'Email', hintText: 'email@example.com'),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          final response = await _userSessionBloc.resetPwd(
                              email: _emailController.text);

                          switch (response.status) {
                            case Status.LOADING:
                              // impossible
                              break;
                            case Status.COMPLETED:
                              showAlertDialog(
                                  context,
                                  'Warning',
                                  'Procedure succesfully completed. '
                                      'Check your email.',
                                  redirectRoute: '/');
                              break;
                            case Status.ERROR:
                              showAlertDialog(
                                  context, 'Error', response.message);
                              break;
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
