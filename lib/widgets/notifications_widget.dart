import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated/paginated_invitations_bloc.dart';
import 'package:cyberdindaroloapp/blocs/user_session_bloc.dart';
import 'package:cyberdindaroloapp/models/invitation_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({Key key}) : super(key: key);

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  StreamSubscription _dataStreamSubscription;

  PaginatedInvitationsBloc _paginatedInvitationsBloc;
  UserSessionBloc _userSessionBloc;

  int nextPage = 1;

  bool isLoading = false;

  List invitations = new List();

  bool dataFetchComplete = false;

  @override
  void initState() {
    _paginatedInvitationsBloc =
        BlocProvider.of<PaginatedInvitationsBloc>(context);

    _userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription?.cancel();
    super.dispose();
  }

  // Fetch invitations and set state to "loading"
  // while fetching
  Future<void> _getMoreData() async {
    if (dataFetchComplete) {
      print("Already fetched all data, exiting.");
      return;
    }

    // Set state to loading
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      _paginatedInvitationsBloc.fetchInvitations(page: nextPage);
    }
  }

  // Listen for invitation changes and set state to "complete"
  _listen() {
    // Subscribe to datas_tream
    _dataStreamSubscription =
        _paginatedInvitationsBloc.pagInvitationsListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          invitations.addAll(event.data.results);
          //print(piggybanks[0].pbName);
          // If there is a next page, then set nextPage += 1
          if (event.data.next != null)
            nextPage++;
          else
            dataFetchComplete = true;

          // Fetch is now complete
          setState(() {
            isLoading = false;
          });
          break;

        case Status.ERROR:
          // If an error occured and if it is token related
          // redirect to login (with autologin : true)
          if (event.message.toLowerCase().contains('token')) {
            showAlertDialog(context, 'Error', event.message,
                redirectRoute: '/');
          } else {
            showAlertDialog(context, 'Error', event.message);
          }
          break;
      }
    });
  }

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    dataFetchComplete = false;
    nextPage = 1;

    invitations = new List();

    // Need await to handle refresh indicator ending callback
    await _getMoreData();
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
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<bool> isInviter(InvitationModel invitation) async {
    Response<UserSessionModel> response =
        await _userSessionBloc.fetchUserSessionWithoutStream();

    switch (response.status) {
      case Status.LOADING:
        // impossible
        break;
      case Status.COMPLETED:
        return invitation.inviter == response.data.user_data.auth_user_id;
        break;
      case Status.ERROR:
        throw Exception(response.message);
        break;
    }
  }

  Widget _buildInvitationTitle(InvitationModel invitation, bool isInviter) {
    if (!isInviter) {
      return RichText(
        text: TextSpan(
          text: 'User ',
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
                text: '${invitation.inviter_username}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' has invited you to join piggybank '),
            TextSpan(
                text: '${invitation.piggybank_name}.',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: 'You have invited ',
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
                text: '${invitation.invited_username}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' to join piggybank '),
            TextSpan(
                text: '${invitation.piggybank_name}.',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
  }

  _manageResponse(response) {
    if (response != null) {
      switch (response.status) {
        case Status.LOADING:
          // impossible
          break;
        case Status.COMPLETED:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Invitation successfully managed'),
          ));
          _handleRefresh();
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
  }

  Widget _getInvitationTile(InvitationModel invitation) {
    return ListTile(
        title: FutureBuilder(
          future: isInviter(invitation),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildInvitationTitle(invitation, snapshot.data);
            }
            return CircularProgressIndicator();
          },
        ),
        subtitle: Text(invitation.invitation_date.toString()),
        leading: FutureBuilder(
          future: isInviter(invitation),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool isInviterRes = snapshot.data;
              if (isInviterRes)
                return Column(
                  children: <Widget>[
                    Icon(Icons.notifications_active),
                    Text(
                      'You',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                );
              else
                return Icon(Icons.notifications_active);
            }
            return CircularProgressIndicator();
          },
        ),
        onTap: () async {
          var choice;
          var response;
          if (!(await isInviter(invitation))) {
            choice = await asyncThreeConfirmDialog(context,
                title: 'Join PiggyBank',
                question_message: 'Do you want to accept this invitation?');
            if (choice != null) {
              switch (choice) {
                case ThreeConfirmAction.CANCEL:
                  break;
                case ThreeConfirmAction.ACCEPT:
                  response = await _paginatedInvitationsBloc.acceptInvitation(
                      id: invitation.id);
                  break;
                case ThreeConfirmAction.DECLINE:
                  response = await _paginatedInvitationsBloc.declineInvitation(
                      id: invitation.id);
                  break;
              }
            }
          } else {
            choice = await asyncConfirmDialog(context,
                title: 'Manage Invitation',
                question_message: 'Do you want to delete this invitation?');
            if (choice != null) {
              switch (choice) {
                case ConfirmAction.CANCEL:
                  break;
                case ConfirmAction.ACCEPT:
                  response = await _paginatedInvitationsBloc.deleteInvitation(
                      id: invitation.id);
                  break;
              }
            }
            _manageResponse(response);
          }
        });
  }

  // ListView builder of invitations
  Widget _buildList() {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(
          indent: 60,
          endIndent: 60,
        );
      },
      //+1 for progressbar
      itemCount: invitations.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == invitations.length) {
          return _buildProgressIndicator();
        } else {
          return _getInvitationTile(invitations[index]);
        }
      },
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  // Build widget:
  // LIST AND INFO LABEL
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
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
        child: Text(dataFetchComplete
            ? "All data is shown"
            : "Scroll down to fetch more data"),
        padding: new EdgeInsets.all(8),
      )),
    ]));
  }
}
