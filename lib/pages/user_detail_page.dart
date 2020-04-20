import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:cyberdindaroloapp/validators.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_info_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class UserDetailPage extends StatefulWidget {
  final UserProfileModel userInstance;
  final bool canEdit;

  const UserDetailPage(
      {Key key, @required this.userInstance, this.canEdit: false})
      : super(key: key);

  @override
  _UserDetailPage createState() {
    return _UserDetailPage();
  }
}

class _UserDetailPage extends State<UserDetailPage> {
  // State vars
  Operation _operation;

  @override
  void initState() {
    _operation = Operation.INFO_VIEW;
    super.initState();
  }

  Widget _getImageHeader() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(height: 135),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/universe.jpg'),
              fit: BoxFit.fill,
            ),
            //shape: BoxShape.circle,
          ),
        ),
        CircleAvatar(
            backgroundColor: Colors.transparent,
            minRadius: 45,
            maxRadius: 60,
            child: getRandomColOfImage()),
      ],
    );
  }

  List<Widget> _infoViewWidgets() {
    return <Widget>[
      _getImageHeader(),
      ListTile(
        title: Text(
          '${widget.userInstance.first_name} ${widget.userInstance.last_name}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Text('${widget.userInstance.email}'),
      ),
      Divider(),
      ListTile(
        title: Text(
          'Username: ${widget.userInstance.username}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      Divider(),
    ];
  }

  List<Widget> _editViewWidgets() {
    return <Widget>[
      _getImageHeader(),
      UserForm(
        userInstance: widget.userInstance,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: !widget.canEdit
            ? <Widget>[]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _operation = Operation.EDIT_VIEW;
                    });
                  },
                )
              ],
        elevation: 0.0,
        title: Text('User Detail',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(),
      //backgroundColor: Color(0xFF333333),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: ListView(
          children: _operation == Operation.INFO_VIEW
              ? _infoViewWidgets()
              : _editViewWidgets(),
        ),
      ),
    );
  }
}

class UserForm extends StatefulWidget {
  final UserProfileModel userInstance;

  const UserForm({Key key, @required this.userInstance}) : super(key: key);

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

  String _pwdErrorMessage = null;

  @override
  void initState() {
    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    _firstNameController =
        new TextEditingController(text: widget.userInstance.first_name);
    _lastNameController =
        new TextEditingController(text: widget.userInstance.last_name);
    _emailController =
        new TextEditingController(text: widget.userInstance.email);

    _pwdAController = new TextEditingController();
    _pwdBController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _validatePasswords(String pwdA, String pwdB) {
    if (!isNullOrEmpty(pwdA) || !isNullOrEmpty(pwdB)) {
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
                  final newInstance = UserProfileModel(
                      auth_user_id: widget.userInstance.auth_user_id,
                      username: widget.userInstance.username,
                      email: _emailController.text,
                      first_name: _firstNameController.text,
                      last_name: _lastNameController.text);

                  final response = await _userSessionBloc.editProfile(
                      oldInstance: widget.userInstance,
                      newInstance: newInstance,
                      newPwd: _pwdAController.text);

                  switch (response?.status) {
                    case Status.LOADING:
                      // impossible
                      break;
                    case Status.COMPLETED:
                      //if (widget.onFormSuccessfullyValidated != null)
                      //widget.onFormSuccessfullyValidated();
                      await showAlertDialog(context, 'Warning',
                          'Edit successfully completed, you\'ll be redirected to login page', redirectRoute: '/');
                      _userSessionBloc.logout();

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
              child: Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
