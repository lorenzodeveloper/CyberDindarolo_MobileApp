import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated/paginated_entries_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_purchases_bloc.dart';
import 'package:cyberdindaroloapp/models/entry_model.dart';
import 'package:cyberdindaroloapp/models/purchase_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:decimal/decimal.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

enum MovementType { ENTRIES, PURCHASES }

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({Key key}) : super(key: key);

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  MovementType _movementType;

  StreamSubscription _dataStreamSubscription;

  PaginatedEntriesBloc _paginatedEntriesBloc;
  PaginatedPurchasesBloc _paginatedPurchasesBloc;

  int _nextPage = 1;

  bool _isLoading = false;

  List _movements = new List();

  bool _dataFetchComplete = false;

  @override
  void initState() {
    _movementType = MovementType.PURCHASES;

    _paginatedEntriesBloc = BlocProvider.of<PaginatedEntriesBloc>(context);
    _paginatedPurchasesBloc = BlocProvider.of<PaginatedPurchasesBloc>(context);

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
    if (_dataFetchComplete) {
      print("Already fetched all data, exiting.");
      return;
    }

    // Set state to loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      if (_movementType == MovementType.ENTRIES)
        _paginatedEntriesBloc.fetchEntries(page: _nextPage);
      else
        _paginatedPurchasesBloc.fetchPurchases(page: _nextPage);
    }
  }

  // Listen for invitation changes and set state to "complete"
  _listen() {
    if (_movementType == MovementType.ENTRIES)
      _listenEntriesStream();
    else
      _listenPurchasesStream();
  }

  _listenEntriesStream() {
    // Subscribe to data stream
    _dataStreamSubscription =
        _paginatedEntriesBloc.pagEntriesListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          _movements.addAll(event.data.results);
          //print(piggybanks[0].pbName);
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

  _listenPurchasesStream() {
    // Subscribe to data stream
    _dataStreamSubscription =
        _paginatedPurchasesBloc.pagPurchasesListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          _movements.addAll(event.data.results);
          //print(piggybanks[0].pbName);
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

    _movements = new List();

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
          opacity: _isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildMovementTile(dynamic movement) {
    if (movement is EntryModel) {
      final EntryModel entry = movement;
      final priceTot = entry.entry_price * Decimal.fromInt(entry.set_quantity);
      return ListTile(
          title: ExpandablePanel(
        header: Text(entry.product_name,
            style: TextStyle(fontWeight: FontWeight.bold)),
        collapsed: Text(
          '+$priceTot PGM',
          style: TextStyle(color: Colors.green),
        ),
        expanded: Column(
          children: <Widget>[
            RichText(
                text: TextSpan(
              text: 'Entered in date ',
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text: '${entry.entry_date.toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' into piggybank '),
                TextSpan(
                    text: '${entry.piggybank_name}.',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '\n\n$priceTot PGM = ${entry.entry_price} PGM '
                        'x ${entry.set_quantity} packs.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            )),
            Container(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteEntry(entry);
                },
              ),
            )
          ],
        ),
      ));
    } else if (movement is PurchaseModel) {
      final PurchaseModel purchase = movement;
      final priceTot =
          purchase.unitary_purchase_price * Decimal.fromInt(purchase.pieces);
      return ListTile(
        title: ExpandablePanel(
          header: Text(
            purchase.product_name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          collapsed: Text(
            '-$priceTot PGM',
            style: TextStyle(color: Colors.red),
          ),
          expanded: Column(
            children: <Widget>[
              RichText(
                  text: TextSpan(
                text: 'Purchased in date ',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: '${purchase.purchase_date.toString()}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' from piggybank '),
                  TextSpan(
                      text: '${purchase.piggybank_name}.',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          '\n\n$priceTot PGM = ${purchase.unitary_purchase_price}'
                          ' PGM x ${purchase.pieces} pieces.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              )),
              Container(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deletePurchase(purchase);
                  },
                ),
              )
            ],
          ),
        ),
      );
    } else {
      throw Exception('Unknown model.');
    }
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
      itemCount: _movements.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _movements.length) {
          return _buildProgressIndicator();
        } else {
          return _buildMovementTile(_movements[index]);
        }
      },
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  _buildMovementSwitch() {
    return ListTile(
      title: Text(
        'Switch to ${_movementType == MovementType.ENTRIES ? 'purchases' : 'entries'}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Icon(
        Icons.swap_horiz,
        color:
            _movementType == MovementType.ENTRIES ? Colors.red : Colors.green,
      ),
      onTap: () {
        switch (_movementType) {
          case MovementType.ENTRIES:
            setState(() {
              _movementType = MovementType.PURCHASES;
            });
            break;
          case MovementType.PURCHASES:
            setState(() {
              _movementType = MovementType.ENTRIES;
            });
            break;
        }
        // reset everything
        _handleRefresh();
        // cancel current subscription and listen to the other stream
        _dataStreamSubscription?.cancel();
        _listen();
      },
    );
  }

  // Build widget:
  // LIST AND INFO LABEL
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      _buildMovementSwitch(),
      Divider(),
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

  _deletePurchase(PurchaseModel purchase) async {
    final confirmation = await asyncConfirmDialog(context,
        title: 'Delete Movement',
        question_message: 'Do you really want to delete this movement?');
    if (confirmation != null && confirmation == ConfirmAction.ACCEPT) {
      final response =
          await _paginatedPurchasesBloc.deletePurchase(id: purchase.id);
      _manageResponse(response);
    }
  }

  _deleteEntry(EntryModel entry) async {
    final confirmation = await asyncConfirmDialog(context,
        title: 'Delete Movement',
        question_message: 'Do you really want to delete this movement?');
    if (confirmation != null && confirmation == ConfirmAction.ACCEPT) {
      final response = await _paginatedEntriesBloc.deleteEntry(id: entry.id);
      _manageResponse(response);
    }
  }

  _manageResponse(Response<bool> response) {
    switch (response.status) {
      case Status.LOADING:
        // impossible
        break;
      case Status.COMPLETED:
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Movement successfully managed.'),
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
