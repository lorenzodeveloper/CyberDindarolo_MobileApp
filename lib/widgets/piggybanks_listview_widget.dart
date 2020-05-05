import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated/paginated_piggybanks_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/piggybank_detail_page.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class PiggyBanksListViewWidget extends StatefulWidget {
  const PiggyBanksListViewWidget({Key key}) : super(key: key);

  @override
  _PiggyBanksListViewWidgetState createState() =>
      _PiggyBanksListViewWidgetState();
}

class _PiggyBanksListViewWidgetState extends State<PiggyBanksListViewWidget> {
  StreamSubscription _dataStreamSubscription;

  PaginatedPiggyBanksBloc _paginatedPiggyBanksBloc;

  int _nextPage = 1;

  bool _isLoading = false;

  List _piggybanks = new List();

  bool _dataFetchComplete = false;

  TextEditingController _searchFieldController;

  @override
  void initState() {
    _paginatedPiggyBanksBloc =
        BlocProvider.of<PaginatedPiggyBanksBloc>(context);
    _searchFieldController = new TextEditingController();
    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription?.cancel();
    _searchFieldController.dispose();
    super.dispose();
  }

  // Fetch piggybanks and set state to "loading"
  // while fetching
  Future<void> _getMoreData() async {
    if (_dataFetchComplete) {
      print("Already fetched all data, exiting.");
      return;
    }

    // Set state to loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      _paginatedPiggyBanksBloc.fetchPiggyBanks(
          page: _nextPage, pattern: _searchFieldController.text);
    }
  }

  // Listen for piggybanks changes and set state to "complete"
  _listen() {
    // Subscribe to datas_tream
    _dataStreamSubscription =
        _paginatedPiggyBanksBloc.pbListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          _piggybanks.addAll(event.data.results);
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
          } else {
            showAlertDialog(context, 'Error', event.message);
          }
          break;
      }
    });
  }

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    _dataFetchComplete = false;
    _nextPage = 1;

    _piggybanks = new List();

    // Need await to handle refresh indicator ending callback
    await _getMoreData();
  }

  Row _buildSearchTextField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Search textField
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchFieldController,
              decoration: InputDecoration(
                  labelText: 'Search for a piggybank (e.g. \'My PiggyBank\')'),
              onEditingComplete: () {
                _handleRefresh();
              },
            ),
          ),
        )
      ],
    );
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
      itemCount: _piggybanks.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _piggybanks.length) {
          return _buildProgressIndicator();
        } else {
          return PiggyBankTile(piggybanks: _piggybanks, index: index);
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
      _buildSearchTextField(),
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
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '(ID: ${piggybanks[index].id}) - ${piggybanks[index].getDescription()}',
            softWrap: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(piggybanks[index].closed ? 'CLOSED' : 'OPEN',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: piggybanks[index].closed ? Colors.red : Colors.green))
        ],
      ),
      leading: Image(
        image: AssetImage('assets/images/pink_pig.png'),
        width: 30,
        height: 30,
      ),
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PiggyBankDetailPage(piggybanks[index].id)));
      },
    );
  }
}
