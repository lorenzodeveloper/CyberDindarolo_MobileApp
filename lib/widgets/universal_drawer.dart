import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:flutter/material.dart';

class DefaultDrawer extends StatefulWidget {
  final int highlitedVoice;

  const DefaultDrawer({Key key, this.highlitedVoice}) : super(key: key);

  @override
  _DefaultDrawerState createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<DefaultDrawer> {
  UserSessionBloc _userSessionBloc;

  @override
  void initState() {
    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);
    _userSessionBloc.fetchUserSession();
    super.initState();
  }

  @override
  void dispose() {
    //_userSessionBloc.dispose();
    super.dispose();
  }

  void pushIfCan(
      {@required BuildContext context,
      @required int current,
      @required String route}) {
    if (widget.highlitedVoice != current) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<UserSessionModel>>(
      stream: _userSessionBloc.userListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              //return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Drawer(
                child: ListView(padding: EdgeInsets.zero, children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountEmail: Text(snapshot.data.data.user_data.email),
                    accountName: Text(snapshot.data.data.user_data.username),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.red[800],
                      child: Image(
                          image: AssetImage('assets/images/pink_pig.png')),
                    ),
                  ),

                  // PiggyBanks
                  ListTile(
                      selected: widget.highlitedVoice == 1,
                      title: Text('PiggyBanks'),
                      leading: Icon(Icons.view_quilt,),
                      onTap: () =>  this.pushIfCan(context: context, current: 1, route: '/home')
                  ),

                  // UserInfo
                  ListTile(
                      selected: widget.highlitedVoice == 2,
                      title: Text('Profile'),
                      leading: Icon(Icons.email,),
                      onTap: () =>  this.pushIfCan(context: context, current: 2, route: '/profile')
                  ),

                ]),
              );
              break;
            case Status.ERROR:
              /*return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () =>
                    _bloc.fetchPiggyBank(widget.selectedPiggybank),
              );*/
              break;
          }
        }
        return Container();
      },
    );
  }
}

/*
class ScaffoldWithDefaultDrawer extends StatelessWidget {

  final Widget body;

  ScaffoldWithDefaultDrawer({this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      drawer: MyDrawer(),
    );
  }
}*/
