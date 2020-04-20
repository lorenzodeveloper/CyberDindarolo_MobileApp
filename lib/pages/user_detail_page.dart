import 'package:cyberdindaroloapp/blocs/paginated/paginated_users_bloc.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

class UserDetailPage extends StatefulWidget {
  final UserProfileModel userInstance;
  final bool canEdit;

  const UserDetailPage({Key key, this.userInstance, this.canEdit: false})
      : super(key: key);

  @override
  _UserDetailPage createState() {
    return _UserDetailPage();
  }
}

class _UserDetailPage extends State<UserDetailPage> {
  PaginatedUsersBloc _paginatedUsersBloc;

  @override
  void initState() {
    _paginatedUsersBloc = BlocProvider.of<PaginatedUsersBloc>(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        actions: !widget.canEdit? <Widget>[] : <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              print('Ok, edit');
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
          children: <Widget>[
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
          ],
        ),
      ),
    );
  }
}
