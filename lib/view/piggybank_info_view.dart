import 'dart:async';

import 'package:cyberdindaroloapp/blocs/credit_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated_participants_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated_stock_bloc.dart';
import 'package:cyberdindaroloapp/blocs/pb_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated_participants_model.dart';
import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/models/stock_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:cyberdindaroloapp/widgets/loading_widget.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../validators.dart';

class PiggyBankInfoPage extends StatefulWidget {
  final int selectedPiggybank;

  const PiggyBankInfoPage(this.selectedPiggybank);

  @override
  _PiggyBankInfoPageState createState() => _PiggyBankInfoPageState();
}

class _PiggyBankInfoPageState extends State<PiggyBankInfoPage> {
  PiggyBankBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PiggyBankBloc(widget.selectedPiggybank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('PiggyBank Info',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        //backgroundColor: Color(0xFF333333),
      ),
      drawer: DefaultDrawer(),
      //backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchPiggyBank(widget.selectedPiggybank),
        child: StreamBuilder<Response<PiggyBankModel>>(
          stream: _bloc.pbListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return PiggyBankWidget(piggyBank: snapshot.data.data);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () =>
                        _bloc.fetchPiggyBank(widget.selectedPiggybank),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class PiggyBankWidget extends StatefulWidget {
  final PiggyBankModel piggyBank;

  PiggyBankWidget({@required this.piggyBank});

  @override
  _PiggyBankWidgetState createState() {
    return _PiggyBankWidgetState();
  }
}

enum Operation { INFO_VIEW, EDIT_VIEW }

// Define a corresponding State class.
// This class holds data related to the form.
class _PiggyBankWidgetState extends State<PiggyBankWidget> {
  final _formKey = GlobalKey<FormState>();

  Operation _operation;

  final unameController = TextEditingController(text: "lorenzo_lamas123");
  final pwdController = TextEditingController(text: "prova1234");
  PaginatedParticipantsBloc _paginatedParticipantsBloc;
  CreditBloc _creditBloc;

  //PaginatedStockBloc _paginatedStockBloc;

  @override
  void initState() {
    super.initState();
    _operation = Operation.INFO_VIEW;
    _paginatedParticipantsBloc = new PaginatedParticipantsBloc();
    _creditBloc = new CreditBloc();

    _paginatedParticipantsBloc.fetchUsersData(piggybank: widget.piggyBank.id);
    _creditBloc.getCredit(piggybank: widget.piggyBank.id);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    unameController.dispose();
    pwdController.dispose();

    _creditBloc.dispose();
    _paginatedParticipantsBloc.dispose();

    super.dispose();
  }

  Widget _buildForm() {
    // TODO
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              // Username field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: usernameValidator,
                decoration: InputDecoration(labelText: 'Enter your username'),
                //controller: unameController,
              ),
              // Pwd field
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: passwordValidator,
                decoration: InputDecoration(labelText: 'Enter your password'),
                obscureText: true,
                //controller: pwdController,
              ),

              RaisedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, otherwise false.
                  //if (_formKey.currentState.validate()) {}
                  setState(() {
                    _operation = Operation.INFO_VIEW;
                    _creditBloc.getCredit(piggybank: widget.piggyBank.id);
                    _paginatedParticipantsBloc.fetchUsersData(
                        piggybank: widget.piggyBank.id);
                  });
                },
                child: Text('Ciao bell'),
              ),
            ])));
  }

  Widget _buildInfoView() {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        // PiggyBank Header: Name, Desc, Credit
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      child: Image(
                        image: AssetImage('assets/images/pink_pig.png'),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.piggyBank.pbName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                        widget.piggyBank.pbDescription == null
                            ? 'No Description'
                            : widget.piggyBank.pbDescription,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black45)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    _getCreditWidget(),
                  ],
                ),
              ),
            ]),
        Divider(),
        // Participants overview
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                _getParticipantsOverviewWidget(),
              ],
            ),
            Column(children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                // TODO: REINDIRIZZAMENTO A PAGINA PARTECIPANTI
                onPressed: () =>
                    print('REINDIRIZZAMENTO A PAGINA DEI PARTECIPANTI'),
              ),
            ]),
          ],
        ),
        Divider(),
        // Edit button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Edit PG'),
              // TODO: EDIT PG
              onPressed: () {
                print('TODO');
                setState(() {
                  _operation = Operation.EDIT_VIEW;
                });
              },
            ),
            RaisedButton(
              child: Text('CLOSE PG'),
              // TODO: CLOSE PG
              onPressed: () {
                print('TODO');

              },
            ),/*
            RaisedButton(
              child: Text('INVITE USER'),
              // TODO: CLOSE PG
              onPressed: () {
                print('TODO');

              },
            ),
            RaisedButton(
              child: Text('INSERT PRODUCT'),
              // TODO: CLOSE PG
              onPressed: () {
                print('TODO');

              },
            )*/
          ],
        ),
        Divider(),
        // STOCK LIST
        Row(
          children: <Widget>[
            StockListViewWidget(
                piggybank_id: widget.piggyBank.id,
                onPurchase: () => print('purchase')),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    switch (_operation) {
      case Operation.INFO_VIEW:
        // TODO: Handle this case.
        return _buildInfoView();
        break;
      case Operation.EDIT_VIEW:
        return _buildForm();
        break;
    }
  }

  _getCreditWidget() {
    return StreamBuilder<Response<Decimal>>(
      stream: _creditBloc.creditStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.data);
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Text(
                '${snapshot.data.data.toString()} PGM',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.lightBlueAccent),
              );
              break;
            case Status.ERROR:
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () =>
                    _creditBloc.getCredit(piggybank: widget.piggyBank.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }

  _getParticipantsOverviewWidget() {
    return StreamBuilder<Response<PaginatedParticipantsModel>>(
      stream: _paginatedParticipantsBloc.pagParticipantsListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Loading(loadingMessage: snapshot.data.message);
              break;
            case Status.COMPLETED:
              return Text(
                  'You and ${snapshot.data.data.count - 1} other users');
              break;
            case Status.ERROR:
              print(snapshot.data.message);
              return Error(
                errorMessage: snapshot.data.message,
                onRetryPressed: () => _paginatedParticipantsBloc.fetchUsersData(
                    piggybank: widget.piggyBank.id),
              );
              break;
          }
        }
        return Container();
      },
    );
  }
}

class StockListViewWidget extends StatefulWidget {
  final int piggybank_id;
  final void Function() onPurchase;

  StockListViewWidget({@required this.piggybank_id, @required this.onPurchase});

  @override
  _StockListViewWidgetState createState() {
    return _StockListViewWidgetState();
  }
}

/*class _StockWidgetState extends State<StockWidget> {

  PaginatedStockBloc _paginatedStockBloc;

  @override
  void initState() {
    _paginatedStockBloc = new PaginatedStockBloc();
    super.initState();
  }

  @override
  void dispose() {
    _paginatedStockBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Ciao bellissimi');
  }

}*/

class _StockListViewWidgetState extends State<StockListViewWidget> {
  StreamSubscription _dataStreamSubscription;

  PaginatedStockBloc _paginatedStockBloc;

  int nextPage = 1;

  bool isLoading = false;

  List stockList = new List();

  bool dataFetchComplete = false;

  @override
  void initState() {
    _paginatedStockBloc = new PaginatedStockBloc();
    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _dataStreamSubscription.cancel();
    _paginatedStockBloc.dispose();
    super.dispose();
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

      _paginatedStockBloc.fetchPiggyBankStock(
          page: nextPage, piggybank: widget.piggybank_id);
    }
  }

  // Listen for piggybanks changes and set state to "complete"
  _listen() {
    // Subscribe to datas_tream
    _dataStreamSubscription =
        _paginatedStockBloc.pagStockListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          stockList.addAll(event.data.results);
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

  // If refresh triggered, fetch data from page 1
  _handleRefresh() async {
    dataFetchComplete = false;
    nextPage = 1;

    stockList = new List();

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
      itemCount: stockList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == stockList.length) {
          return _buildProgressIndicator();
        } else {
          return _getStockTile(stockList[index]);
        }
      },
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  // Build widget:
  // LIST AND INFO LABEL
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) =>
                  _onEndScroll(scrollNotification),
              child: RefreshIndicator(
                child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 300.0,
                    ),
                    child: _buildList()),
                onRefresh: () => _handleRefresh(),
              ),
            ),
            Center(
                child: Padding(
                  child: Text(dataFetchComplete
                      ? "All data is shown"
                      : "Scroll down to fetch more data"),
                  padding: new EdgeInsets.all(8),
                )),
          ]),
    );
  }

  Widget _getStockTile(StockModel stockModel) {
    return Row(
      children: <Widget>[
        // PRODUCT NAME
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Text(stockModel.product_name),
            ],
          ),
        ),
        // PRODUCT NAME
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Text(stockModel.entered_by_username),
            ],
          ),
        ),
        // pieces
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(stockModel.pieces.toString()),
            ],
          ),
        ),
        // unitary_price
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(stockModel.unitary_price.toString()),
            ],
          ),
        ),
        // PRODUCT NAME
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              InkWell(
                child: Text('BUY'),
                //TODO: BUY
                onTap: () => print('TODO'),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
