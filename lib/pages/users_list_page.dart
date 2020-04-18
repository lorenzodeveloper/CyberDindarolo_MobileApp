import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_participants_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_users_bloc.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';

class UsersListViewPage extends StatelessWidget {
  final PiggyBankModel piggybankInstance;

  const UsersListViewPage({Key key, this.piggybankInstance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
            piggybankInstance == null
                ? 'Users list'
                : 'Participants of \'${piggybankInstance.pbName}\'',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(highlitedVoice: Voice.USERS,),
      body: UsersListViewWidget(
        piggybank_id: piggybankInstance?.id,
      ),
    );
  }
}

class UsersListViewWidget extends StatefulWidget {
  final int piggybank_id;

  const UsersListViewWidget({Key key, this.piggybank_id}) : super(key: key);

  @override
  _UsersListViewWidgetState createState() {
    return _UsersListViewWidgetState();
  }
}

class _UsersListViewWidgetState extends State<UsersListViewWidget> {
  PaginatedParticipantsBloc _paginatedParticipantsBloc;
  PaginatedUsersBloc _paginatedUsersBloc;

  StreamSubscription _usersDataStreamSubscription;
  StreamSubscription _participantsDataStreamSubscription;

  // State vars
  int nextPage = 1;

  bool isLoading = false;

  List usersList;

  bool dataFetchComplete = false;

  @override
  void initState() {
    _paginatedParticipantsBloc =
        BlocProvider.of<PaginatedParticipantsBloc>(context);
    _paginatedUsersBloc = BlocProvider.of<PaginatedUsersBloc>(context);

    usersList = new List();

    _listenStream();
    _fetchData();

    super.initState();
  }

  @override
  void dispose() {
    _usersDataStreamSubscription?.cancel();
    _participantsDataStreamSubscription?.cancel();
    super.dispose();
  }

  _listenStream() {
    // participant state or users state
    if (widget.piggybank_id != null) {
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
          usersList.addAll(event.data.results);
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
          usersList.addAll(event.data.results);
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
          }
          break;
      }
    });
  }

  _fetchData() {
    // participant state or users state
    if (widget.piggybank_id != null) {
      _paginatedParticipantsBloc.fetchUsersData(piggybank: widget.piggybank_id);
    } else {
      _paginatedUsersBloc.fetchUsers();
    }
  }

  // Fetch stock and set state to "loading"
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

      _fetchData();
    }
  }

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    dataFetchComplete = false;
    nextPage = 1;

    usersList = new List();

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

  Widget _getUserListTile(dynamic instance) {
    var title = '${instance.first_name} ${instance.last_name}';
    var subtitle = '';

    // participant state or users state
    if (widget.piggybank_id != null) {
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
        minRadius: 10,
        maxRadius: 30,
        child: Image(
          image: AssetImage('assets/images/pink_pig.png'),
        ),
      ),
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
      itemCount: usersList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == usersList.length) {
          return _buildProgressIndicator();
        } else {
          return _getUserListTile(usersList[index]);
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
