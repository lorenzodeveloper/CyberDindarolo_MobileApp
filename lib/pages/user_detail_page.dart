import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/login_page.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_info_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:cyberdindaroloapp/widgets/user_form.dart';
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
  _UserDetailPageState createState() {
    return _UserDetailPageState();
  }
}

class _UserDetailPageState extends State<UserDetailPage> {
  // State vars
  Operation _operation;

  UserSessionBloc _userSessionBloc;

  @override
  void initState() {
    _operation = Operation.INFO_VIEW;
    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);
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
                  icon: _operation == Operation.INFO_VIEW
                      ? Icon(Icons.edit)
                      : Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      if (_operation == Operation.INFO_VIEW)
                        _operation = Operation.EDIT_VIEW;
                      else
                        _operation = Operation.INFO_VIEW;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteUser();
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

  _deleteUser() async {
    final ConfirmAction confirmation = await asyncConfirmDialog(context,
        title: "Do you really want to delete your account?",
        question_message: "You won't be able to rollback once you "
            "decide to delete your account. "
            "All the piggybanks you have created won't be deleted/closed.");
    switch (confirmation) {
      case ConfirmAction.CANCEL:
        break;
      case ConfirmAction.ACCEPT:
        // Close request
        final response = await _userSessionBloc
            .deleteAccount(id: widget.userInstance.auth_user_id);

        // Handle response
        if (response.status == Status.COMPLETED) {
          // redirect and refresh piggybanks list
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LoginPage(
                    autoLogin: false,
                  )));
        } else if (response.status == Status.ERROR) {
          // Show error message
          if (response.message.toLowerCase().contains('token')) {
            showAlertDialog(context, 'Error', response.message,
                redirectRoute: '/');
          } else {
            showAlertDialog(context, 'Error', response.message);
          }
        }
        break;
    }
  }
}
