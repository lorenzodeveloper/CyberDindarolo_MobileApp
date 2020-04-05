import 'dart:async';

import 'package:cyberdindaroloapp/alerts.dart';
import 'package:cyberdindaroloapp/blocs/paginated_pbs_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/view/pb_view.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

enum Choice { PIGGYBANKS, NOTIFICATIONS, HISTORY }

class PiggyBanksPage extends StatefulWidget {
  PiggyBanksPage({Key key}) : super(key: key);

  @override
  _PiggyBanksPageState createState() => _PiggyBanksPageState();
}

class _PiggyBanksPageState extends State<PiggyBanksPage> {
  PaginatedPiggyBanksBloc _bloc;
  Choice selectedChoice;

  @override
  void initState() {
    _bloc = PaginatedPiggyBanksBloc();
    selectedChoice = Choice.PIGGYBANKS;
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _chosenWidget() {
    switch (selectedChoice) {
      case Choice.PIGGYBANKS:
        return BlocProvider(
          bloc: _bloc,
          child: PiggyBankListView(),
        );
        break;
      case Choice.NOTIFICATIONS:
        // TODO: Handle this case.
        break;
      case Choice.HISTORY:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PiggyBanks'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.android),
              color: selectedChoice == Choice.PIGGYBANKS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showPiggyBanks(),
            ),
            IconButton(
              icon: selectedChoice == Choice.NOTIFICATIONS
                  ? Icon(Icons.notifications)
                  : Icon(Icons.notifications_none),
              color: selectedChoice == Choice.NOTIFICATIONS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showNotifications(),
            ),
            IconButton(
              icon: Icon(Icons.history),
              color: selectedChoice == Choice.HISTORY
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showMovementsHistory(),
            ),
          ],
        ),
        drawer: DefaultDrawer(
          highlitedVoice: Voice.PIGGYBANKS,
        ),
        body: _chosenWidget(),
        resizeToAvoidBottomInset: false);
  }

  _showNotifications() {
    setState(() {
      selectedChoice = Choice.NOTIFICATIONS;
    });
  }

  _showPiggyBanks() {
    setState(() {
      selectedChoice = Choice.PIGGYBANKS;
    });
  }

  _showMovementsHistory() {
    setState(() {
      selectedChoice = Choice.HISTORY;
    });
  }
}

class PiggyBankListView extends StatefulWidget {
  const PiggyBankListView({Key key}) : super(key: key);

  @override
  _PiggyBankListViewState createState() => _PiggyBankListViewState();
}

class _PiggyBankListViewState extends State<PiggyBankListView> {
  StreamSubscription _dataStreamSubscription;

  PaginatedPiggyBanksBloc _piggyBankBloc;

  int nextPage = 1;

  bool isLoading = false;

  List piggybanks = new List();

  bool dataFetchComplete = false;

  @override
  void initState() {
    _piggyBankBloc = BlocProvider.of<PaginatedPiggyBanksBloc>(context);
    if (_piggyBankBloc.isClosed) _piggyBankBloc = new PaginatedPiggyBanksBloc();
    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription.cancel();
    _piggyBankBloc.dispose();
    super.dispose();
  }

  // Fetch piggybanks and set state to "loading"
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

      _piggyBankBloc.fetchPiggyBanks(page: nextPage);
    }
  }

  // Listen for piggybanks changes and set state to "complete"
  _listen() {
    // Subscribe to datas_tream
    _dataStreamSubscription = _piggyBankBloc.pbListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          piggybanks.addAll(event.data.results);
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
          }
          break;
      }
    });
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

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    dataFetchComplete = false;
    nextPage = 1;

    piggybanks = new List();

    // Need await to handle refresh indicator ending callback
    await _getMoreData();
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
      itemCount: piggybanks.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == piggybanks.length) {
          return _buildProgressIndicator();
        } else {
          return PiggyBankTile(piggybanks: piggybanks, index: index);
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
            ? "Alla data is shown"
            : "Scroll down to fetch more data"),
        padding: new EdgeInsets.all(8),
      )),
    ]));
  }
}

class PiggyBankTile extends StatelessWidget {
  const PiggyBankTile(
      {Key key, @required this.piggybanks, @required this.index})
      : super(key: key);

  final List piggybanks;
  final int index;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: Text(
        piggybanks[index].pbName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(piggybanks[index].pbDescription == null
          ? 'No description.'
          : piggybanks[index].pbDescription),
      leading: Image(
        image: AssetImage('assets/images/pink_pig.png'),
        width: 30,
        height: 30,
      ),
      onTap: () async {
        //print('Clicked ${piggybanks[index]}');
        var result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PiggyBankInfoPage(piggybanks[index].id)));
      },
    );
  }
}
