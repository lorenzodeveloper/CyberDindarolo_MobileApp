import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_purchases_bloc.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_stock_bloc.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/models/stock_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:flutter/material.dart';

import '../alerts.dart';

class StockListViewWidget extends StatefulWidget {
  final int piggybank_id;
  final bool closed;
  final void Function() onPurchase;

  StockListViewWidget(
      {@required this.piggybank_id, @required this.onPurchase, this.closed});

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
  PaginatedProductsBloc _paginatedProductsBloc;

  // State vars
  int nextPage = 1;

  bool isLoading = false;

  List stockList;

  bool dataFetchComplete = false;

  @override
  void initState() {
    //_paginatedStockBloc = new PaginatedStockBloc();
    //_paginatedPurchasesBloc = new PaginatedPurchasesBloc();
    //_paginatedProductsBloc = new PaginatedProductsBloc();

    stockList = new List();

    _paginatedStockBloc = BlocProvider.of<PaginatedStockBloc>(context);
    _paginatedPurchasesBloc = BlocProvider.of<PaginatedPurchasesBloc>(context);
    _paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);

    _listenStockStream();

    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _stockDataStreamSubscription.cancel();
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
      {@required String text,
      @required int flex,
      TextStyle style,
      Function() onTap}) {
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
            onTap: () async {
              final Response<ProductModel> response =
                  await _paginatedProductsBloc.getProduct(
                      id: stockModel.product);
              switch (response.status) {
                case Status.LOADING:
                  break;
                case Status.COMPLETED:
                  // Show toast with product info
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          response.data.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          response.data.description == null
                              ? 'No description'
                              : response.data.description,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        Text('${response.data.pieces} pieces per set'),
                        Divider(),
                        Text(
                            'Originally inserted by ${stockModel.entered_by_username} in date ${stockModel.entry_date.toString()} for piggybank with id ${response.data.validForPiggyBank}'),
                      ],
                    ),
                  ));
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
            }),

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
                onPressed: (stockModel.pieces <= 0 || widget.closed)
                    ? null
                    : () async {
                        print(widget.closed);
                        await _onPurchase(stockModel);
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnListDescriptor() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _textInExpColumn(
            text: 'Product Name',
            flex: 3,
            style: TextStyle(fontStyle: FontStyle.italic)),
        _textInExpColumn(
            text: 'Quantity',
            flex: 2,
            style: TextStyle(fontStyle: FontStyle.italic)),
        _textInExpColumn(
            text: 'Unitary Cost',
            flex: 3,
            style: TextStyle(fontStyle: FontStyle.italic)),
        _textInExpColumn(
            text: 'Buy',
            flex: 2,
            style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Future _onPurchase(StockModel stockModel) async {
    final int quantity = await asyncInputDialog(context,
        title: 'Quantity:', min: 1, max: stockModel.pieces);

    if (quantity != null) {
      final response = await _paginatedPurchasesBloc.buyProductFromStock(
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
        _buildColumnListDescriptor(),
        Divider(),
        NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) =>
              _onEndScroll(scrollNotification),
          child: RefreshIndicator(
            child: ConstrainedBox(
                constraints: new BoxConstraints(
                  minHeight: 200.0,
                  maxHeight: 350.0,
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
