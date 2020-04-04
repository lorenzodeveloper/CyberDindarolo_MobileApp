import 'dart:async';

import 'package:cyberdindaroloapp/alerts.dart';
import 'package:cyberdindaroloapp/blocs/paginated_pbs_bloc.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/view/pb_view.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer.dart';
import 'package:flutter/material.dart';

import '../bloc_provider.dart';

enum Choice { PIGGYBANKS, INVITATIONS, MOVEMENTS }

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
      case Choice.INVITATIONS:
        // TODO: Handle this case.
        break;
      case Choice.MOVEMENTS:
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
              icon: selectedChoice == Choice.INVITATIONS
                  ? Icon(Icons.notifications)
                  : Icon(Icons.notifications_none),
              color: selectedChoice == Choice.INVITATIONS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showNotifications(),
            ),
            IconButton(
              icon: Icon(Icons.history),
              color: selectedChoice == Choice.MOVEMENTS
                  ? Colors.lightBlueAccent
                  : Colors.white,
              onPressed: () => _showMovementsHistory(),
            ),
          ],
        ),
        drawer: DefaultDrawer(
          highlitedVoice: 1,
        ),
        body: _chosenWidget(),
        resizeToAvoidBottomInset: false);
  }

  _showNotifications() {
    setState(() {
      selectedChoice = Choice.INVITATIONS;
    });
  }

  _showPiggyBanks() {
    setState(() {
      selectedChoice = Choice.PIGGYBANKS;
    });
  }

  _showMovementsHistory() {
    setState(() {
      selectedChoice = Choice.MOVEMENTS;
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

  void _getMoreData() async {
    if (dataFetchComplete) {
      print("Already fetched all data, exiting.");
      return;
    }

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      _piggyBankBloc.fetchPiggyBanks(page: nextPage);
    }
  }

  @override
  void initState() {
    _piggyBankBloc = BlocProvider.of<PaginatedPiggyBanksBloc>(context);
    if (_piggyBankBloc.isClosed) _piggyBankBloc = new PaginatedPiggyBanksBloc();
    _listen();
    this._getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription.cancel();
    _piggyBankBloc.dispose();
    super.dispose();
  }

  _listen() {
    _dataStreamSubscription = _piggyBankBloc.pbListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          piggybanks.addAll(event.data.results);
          print(piggybanks[0].pbName);
          if (event.data.next != null)
            nextPage++;
          else
            dataFetchComplete = true;

          setState(() {
            isLoading = false;
          });
          break;

        case Status.ERROR:
          if (event.message.toLowerCase().contains('token')) {
            showAlertDialog(context, 'Error', event.message,
                redirectRoute: '/');
          }
          break;
      }
    });
  }

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

  Widget _buildList() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.black12,
      ),
      //+1 for progressbar
      itemCount: piggybanks.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == piggybanks.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            title: Text(piggybanks[index].pbName, style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Text(piggybanks[index].pbDescription == null
                ? 'No description.'
                : piggybanks[index].pbDescription),
            leading: Image(
              image: AssetImage('assets/images/pink_pig.png'),
              width: 30,
              height: 30,
            ),
            onTap: () async {
              print('Clicked ${piggybanks[index]}');
              var result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PiggyBankInfoPage(piggybanks[index].id)));
            },
          );
        }
      },
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      if (metrics.pixels >= metrics.maxScrollExtent && !metrics.outOfRange) {
        setState(() {
          _getMoreData();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            _onEndScroll(scrollNotification.metrics);
            return true;
          }
          return false;
        },
        child: Expanded(child: _buildList()),
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

/*
class PiggyBankList extends StatefulWidget {
  final PaginatedPiggyBanksModel pbList;
  final void Function() callback;

  const PiggyBankList({Key key, this.pbList, this.callback}) : super(key: key);

  @override
  _PiggyBankListState createState() => _PiggyBankListState();
}

class _PiggyBankListState extends State<PiggyBankList> {
  ScrollController _controller;

  Widget _buildList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 1.0,
            ),
            child: InkWell(
                onTap: () async {
                  var result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => PiggyBankInfoPage(
                              widget.pbList.results[index].id)));
                },
                child: SizedBox(
                  height: 65,
                  child: Container(
                    color: Color(0xFF333333),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        widget.pbList.results[index].pbName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'Roboto'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                )));
      },
      itemCount: widget.pbList.results.length,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      controller: _controller,
    );
  }

  _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent && !metrics.outOfRange) {
      print("reached bottom");
      if (widget.pbList.next != null) {
        print(widget.pbList.next);
        widget.callback();
        //_controller.jumpTo(widget.pbList.count - 2 * 65.0);
      }
    }
  }

  @override
  void initState() {
    _controller = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xFF202020),
        body: new Container(
            child: Column(children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                _onEndScroll(scrollNotification.metrics);
                return true;
              }
              return false;
            },
            child: Expanded(child: _buildList()),
          ),
        ])));
  }
}
*/
