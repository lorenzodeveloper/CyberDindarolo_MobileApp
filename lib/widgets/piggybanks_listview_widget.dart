import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated/paginated_piggybanks_bloc.dart';
import 'package:cyberdindaroloapp/blocs/piggybank_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/piggybank_info_main_page.dart';
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

  PaginatedPiggyBanksBloc _piggyBankBloc;

  int nextPage = 1;

  bool isLoading = false;

  List piggybanks = new List();

  bool dataFetchComplete = false;

  @override
  void initState() {
    _piggyBankBloc = BlocProvider.of<PaginatedPiggyBanksBloc>(context);
    //if (_piggyBankBloc.isClosed) _piggyBankBloc = new PaginatedPiggyBanksBloc();
    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription.cancel();
    //_piggyBankBloc.dispose();
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

    piggybanks = new List();

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
            piggybanks[index].getDescription(),
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
        //print('Clicked ${piggybanks[index]}');
        var result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlocProvider(
                bloc: PiggyBankBloc(),
                child: PiggyBankInfoPage(piggybanks[index].id))));
      },
    );
  }
}
