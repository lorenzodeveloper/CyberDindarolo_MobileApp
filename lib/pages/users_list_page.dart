import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_participants_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_users_bloc.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/participant_model.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/user_detail_page.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';

class UsersListViewPage extends StatelessWidget {
  final PiggyBankModel piggybankInstance;

  final bool isInviting;

  const UsersListViewPage(
      {Key key, this.piggybankInstance, this.isInviting: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
            piggybankInstance == null || isInviting
                ? 'Users list'
                : 'Participants of \'${piggybankInstance.pbName}\'',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(
        highlitedVoice: Voice.USERS,
      ),
      body: UsersListViewWidget(
        piggybank_id: piggybankInstance?.id,
        isInviting: isInviting,
      ),
    );
  }
}

class UsersListViewWidget extends StatefulWidget {
  final int piggybank_id;

  final bool isInviting;

  const UsersListViewWidget(
      {Key key, this.piggybank_id, this.isInviting: false})
      : super(key: key);

  @override
  _UsersListViewWidgetState createState() {
    return _UsersListViewWidgetState();
  }
}

class _UsersListViewWidgetState extends State<UsersListViewWidget> {
  PaginatedParticipantsBloc _paginatedParticipantsBloc;
  PaginatedUsersBloc _paginatedUsersBloc;

  UserSessionBloc _userSessionBloc;

  StreamSubscription _usersDataStreamSubscription;
  StreamSubscription _participantsDataStreamSubscription;

  TextEditingController _searchPatternController;

  // State vars
  int _nextPage = 1;

  bool _isLoading = false;

  List _usersList;

  bool _dataFetchComplete = false;

  @override
  void initState() {
    _paginatedParticipantsBloc =
        BlocProvider.of<PaginatedParticipantsBloc>(context);
    _paginatedUsersBloc = BlocProvider.of<PaginatedUsersBloc>(context);

    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    _usersList = new List();

    _listenStream();
    _getMoreData();

    _searchPatternController = new TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _searchPatternController.dispose();
    _usersDataStreamSubscription?.cancel();
    _participantsDataStreamSubscription?.cancel();
    super.dispose();
  }

  _listenStream() {
    // participant state or users state
    if (widget.piggybank_id != null && !widget.isInviting) {
      _listenParticipantStream();
    } else {
      _listenUsersStream();
    }
  }

  void _listenUsersStream() {
    _usersDataStreamSubscription =
        _paginatedUsersBloc.pagUsersListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to users list
          _usersList.addAll(event.data.results);
          // If there is a next page, then set nextPage += 1
          if (event.data.next != null)
            _nextPage++;
          else
            _dataFetchComplete = true;

          // Fetch is now complete
          setState(() {
            _isLoading = false;
          });
          break;

        case Status.ERROR:
          // If an error occured and if it is token related
          // redirect to login (with autologin : true)
          if (event.message.toLowerCase().contains('token')) {
            showAlertDialog(context, 'Error', event.message,
                redirectRoute: '/');
          }
          break;
      }
    });
  }

  void _listenParticipantStream() {
    _participantsDataStreamSubscription =
        _paginatedParticipantsBloc.pagParticipantsListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to users list
          _usersList.addAll(event.data.results);
          // If there is a next page, then set nextPage += 1
          if (event.data.next != null)
            _nextPage++;
          else
            _dataFetchComplete = true;

          // Fetch is now complete
          setState(() {
            _isLoading = false;
          });
          break;

        case Status.ERROR:
          // If an error occured and if it is token related
          // redirect to login (with autologin : true)
          if (event.message.toLowerCase().contains('token')) {
            showAlertDialog(context, 'Error', event.message,
                redirectRoute: '/');
          }
          break;
      }
    });
  }

  _fetchData({String pattern}) {
    // participant state or users state
    if (widget.piggybank_id != null && !widget.isInviting) {
      _paginatedParticipantsBloc.fetchParticipants(
          page: _nextPage, piggybank: widget.piggybank_id);
    } else {
      _paginatedUsersBloc.fetchUsers(page: _nextPage, pattern: pattern);
    }
  }

  // Fetch stock and set state to "loading"
  // while fetching
  Future<void> _getMoreData({String pattern}) async {
    if (_dataFetchComplete) {
      print("Already fetched all data, exiting.");
      return;
    }

    // Set state to loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      _fetchData(pattern: pattern);
    }
  }

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    _dataFetchComplete = false;
    _nextPage = 1;

    _usersList = new List();

    // Need await to handle refresh indicator ending callback
    await _getMoreData(pattern: _searchPatternController.text);
  }

  // Callback of scrollNotification listener
  // If scroll reached the bottom, try to fetch more data
  _onEndScroll(ScrollNotification scrollNotification) {
    {
      if (scrollNotification is ScrollEndNotification) {
        var metrics = scrollNotification.metrics;
        if (metrics.pixels >= metrics.maxScrollExtent && !metrics.outOfRange) {
          _getMoreData();
        }
      }
      return false;
    }
  }

  // Build the circular progress indicator in listview
  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _getUserListTile(dynamic instance) {
    var title = '${instance.first_name} ${instance.last_name}';
    var subtitle = '';

    // participant state or users state
    if (widget.piggybank_id != null && !widget.isInviting) {
      subtitle = 'CR: ${instance.credit.toString()} - ${instance.username}';
    } else {
      subtitle = '${instance.username}';
    }

    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      leading: CircleAvatar(
          minRadius: 15,
          maxRadius: 30,
          backgroundColor: Colors.transparent,
          child: getRandomColOfImage()),
      onTap: () async {
        // if participants / user list view
        if (widget.piggybank_id != null && widget.isInviting) {
          var res = await asyncConfirmDialog(context,
              title: 'Invite user',
              question_message:
                  'Do you want ${instance.username} to join this PG?');
          if (res == ConfirmAction.ACCEPT) {
            Navigator.of(context).pop(instance.auth_user_id);
          }
        } else {
          UserProfileModel convertedInstance;
          if (instance is UserProfileModel) {
            convertedInstance = instance;
          } else if (instance is ParticipantModel) {
            final response =
                await _paginatedUsersBloc.getUser(id: instance.auth_user_id);
            switch (response.status) {
              case Status.LOADING:
                // impossible
                break;
              case Status.COMPLETED:
                convertedInstance = response.data;
                break;
              case Status.ERROR:
                throw Exception(response.message);
                break;
            }
          } else {
            throw Exception('Can\'t convert user instance.');
          }

          Response<UserSessionModel> response =
              await _userSessionBloc.fetchUserSessionWithoutStream();

          switch (response.status) {
            case Status.LOADING:
              // impossible
              break;
            case Status.COMPLETED:
              if (convertedInstance.auth_user_id !=
                  response.data.user_data.auth_user_id) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserDetailPage(
                          userInstance: convertedInstance,
                        )));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('You'),
                ));
              }
              break;
            case Status.ERROR:
              throw Exception(response.message);
              break;
          }
        }
      },
    );
  }

  // ListView builder of piggybanks
  Widget _buildList() {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(
          indent: 60,
          endIndent: 60,
        );
      },
      //+1 for progressbar
      itemCount: _usersList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _usersList.length) {
          return _buildProgressIndicator();
        } else {
          return _getUserListTile(_usersList[index]);
        }
      },
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        enabled: widget.piggybank_id == null || widget.isInviting,
        controller: _searchPatternController,
        decoration: InputDecoration(
            labelText: 'Search user by username or email...',
            hintText: 'e.g. user1 or user1@example.com'),
        onEditingComplete: () {
          _nextPage = 1;
          _usersList = new List();
          _dataFetchComplete = false;
          _getMoreData(pattern: _searchPatternController.text);
        },
      ),
    );
  }

  // Build widget:
  // LIST AND INFO LABEL
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      _buildSearchField(),
      NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) =>
            _onEndScroll(scrollNotification),
        child: Expanded(
            child: RefreshIndicator(
          child: _buildList(),
          onRefresh: () => _handleRefresh(),
        )),
      ),
      Center(
          child: Padding(
        child: Text(_dataFetchComplete
            ? "All data is shown"
            : "Scroll down to fetch more data"),
        padding: new EdgeInsets.all(8),
      )),
    ]));
  }
}
