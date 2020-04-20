import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/login_page.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:flutter/material.dart';

enum Voice { PIGGYBANKS, USERS, PRODUCTS, LOGOUT }

class DefaultDrawer extends StatefulWidget {
  final Voice highlitedVoice;

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
    super.dispose();
  }

  void pushIfCan(
      {@required BuildContext context,
      @required Voice current,
      @required String route}) {
    if (widget.highlitedVoice != current) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (route != '/') {
        Navigator.of(context).pushReplacementNamed(route);
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginPage(
                  autoLogin: false,
                )));
      }
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
                        child: Stack(
                          children: <Widget>[
                            getRandomColOfImage(),
                            Container(
                              padding: EdgeInsets.fromLTRB(18, 0, 0, 0),
                                alignment: Alignment.center,
                                child: Text(
                                  '${snapshot.data.data.getInitials()}',
                                  style: TextStyle(color: Colors.white, fontSize: 27),
                                )),
                          ],
                        )),
                  ),

                  // PiggyBanks
                  ListTile(
                      selected: widget.highlitedVoice == Voice.PIGGYBANKS,
                      title: Text('PiggyBanks'),
                      leading: Icon(
                        Icons.home,
                      ),
                      onTap: () => this.pushIfCan(
                          context: context,
                          current: Voice.PIGGYBANKS,
                          route: '/home')),

                  // Users
                  ListTile(
                      selected: widget.highlitedVoice == Voice.USERS,
                      title: Text('Users'),
                      leading: Icon(
                        Icons.account_circle,
                      ),
                      onTap: () => this.pushIfCan(
                          context: context,
                          current: Voice.USERS,
                          route: '/users')),

                  // Products
                  ListTile(
                      selected: widget.highlitedVoice == Voice.PRODUCTS,
                      title: Text('Products'),
                      leading: Icon(
                        Icons.local_grocery_store,
                      ),
                      onTap: () => this.pushIfCan(
                          context: context,
                          current: Voice.PRODUCTS,
                          route: '/products')),

                  Divider(),

                  // Logout
                  ListTile(
                      selected: widget.highlitedVoice == Voice.LOGOUT,
                      title: Text('Logout'),
                      leading: Icon(
                        Icons.exit_to_app,
                      ),
                      onTap: () async {
                        await _userSessionBloc.logout();
                        this.pushIfCan(
                            context: context,
                            current: Voice.LOGOUT,
                            route: '/');
                      }),
                ]),
              );
              break;
            case Status.ERROR:
              return Error(
                  errorMessage: snapshot.data.message, onRetryPressed: () {});
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
