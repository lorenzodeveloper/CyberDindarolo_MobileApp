import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated_purchases_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated_stock_bloc.dart';
import 'package:cyberdindaroloapp/models/stock_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:flutter/material.dart';
import '../alerts.dart';

class StockListViewWidget extends StatefulWidget {
  final int piggybank_id;
  final void Function() onPurchase;

  StockListViewWidget({@required this.piggybank_id, @required this.onPurchase});

  @override
  _StockListViewWidgetState createState() {
    return _StockListViewWidgetState();
  }
}

// Returns an "infinite" List View of stock in a certain piggybank
class _StockListViewWidgetState extends State<StockListViewWidget> {
  // Stock stream listener
  StreamSubscription _stockDataStreamSubscription;

  // Blocs
  PaginatedStockBloc _paginatedStockBloc;
  PaginatedPurchasesBloc _paginatedPurchasesBloc;

  // State vars
  int nextPage = 1;

  bool isLoading = false;

  List stockList = new List();

  bool dataFetchComplete = false;

  // This field is used inside purchase listener to retrieve
  // the current selected item from stock
  StockModel _purchasedItem;

  int _purchasedQty;

  @override
  void initState() {
    _paginatedStockBloc = new PaginatedStockBloc();
    _paginatedPurchasesBloc = new PaginatedPurchasesBloc();

    _listenStockStream();

    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _stockDataStreamSubscription.cancel();
    _paginatedStockBloc.dispose();
    _paginatedPurchasesBloc.dispose();
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

  // Listen for stock changes and set state to "complete"
  _listenStockStream() {
    // Subscribe to datas_tream
    _stockDataStreamSubscription =
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

  // ListView builder of stock
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

  Expanded _textInExpColumn(
      {@required String text, @required int flex, TextStyle style, Function() onTap}) {
    // returns a Text widget inside an expanded column
    return Expanded(
      flex: flex,
      child: Column(
        children: <Widget>[
          InkWell(
            child: Text(
              text,
              style: style,
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _getStockTile(StockModel stockModel) {
    return Row(
      children: <Widget>[
        // PRODUCT NAME
        _textInExpColumn(
            text: stockModel.product_name,
            flex: 2,
            style: TextStyle(fontWeight: FontWeight.bold),
            onTap: () {
              // TODO: When user clicks on product, show info
              // TODO: Make request to products and also snackbar product info
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Originally inserted by ${stockModel
                    .entered_by_username} in date ${stockModel.entry_date
                    .toString()}"),
              ));
            }
        ),

        // pieces
        _textInExpColumn(
            text: stockModel.pieces.toString(),
            flex: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: stockModel.pieces > 0 ? Colors.green : Colors.red,
            )),

        // unitary_price
        _textInExpColumn(
            text: stockModel.unitary_price.toString() + ' PGM',
            flex: 2,
            style: TextStyle(fontWeight: FontWeight.bold)),

        // PRODUCT NAME
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.shopping_basket),
                onPressed: (stockModel.pieces <= 0)
                    ? null
                    : () async {
                        await _onPurchase(stockModel);
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _onPurchase(StockModel stockModel) async {
    final int quantity = await asyncInputDialog(context,
        title: 'Quantity:', min: 1, max: stockModel.pieces);

    if (quantity != null) {
      final response =
        await _paginatedPurchasesBloc.buyProductFromStock(
          product: stockModel.product,
          piggybank: widget.piggybank_id,
          pieces: quantity);

      switch (response.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          setState(() {
            stockModel.pieces -= quantity;
          });
          // Parent callback -> for credit update
          widget.onPurchase();
          break;

        case Status.ERROR:
        // If an error occured and if it is token related
        // redirect to login (with autologin : true)
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
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
}
