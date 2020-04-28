import 'dart:async';

import 'package:cyberdindaroloapp/blocs/paginated/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/product_detail_page.dart';
import 'package:cyberdindaroloapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

class ProductsListViewWidget extends StatefulWidget {
  @override
  _ProductsListViewWidgetState createState() {
    return _ProductsListViewWidgetState();
  }
}

class _ProductsListViewWidgetState extends State<ProductsListViewWidget> {
  StreamSubscription _dataStreamSubscription;

  int _nextPage = 1;

  bool _isLoading = false;

  List _products = new List();

  bool _dataFetchComplete = false;

  PaginatedProductsBloc _paginatedProductsBloc;
  TextEditingController _searchFieldController;

  @override
  void initState() {
    _paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);
    _searchFieldController = new TextEditingController();

    _listen();
    _getMoreData();
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
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

      _paginatedProductsBloc.fetchProducts(
          page: _nextPage, pattern: _searchFieldController.text);
    }
  }

  // Listen for invitation changes and set state to "complete"
  _listen() {
    // Subscribe to datas_tream
    _dataStreamSubscription =
        _paginatedProductsBloc.pagProductsListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          // Add data to piggybanks list
          _products.addAll(event.data.results);
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

    _products = new List();

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
                  labelText: 'Search for a product (e.g. \'Chicken\')'),
              onEditingComplete: () {
                _handleRefresh();
              },
            ),
          ),
        )
      ],
    );
  }

  ListTile _buildProductTile(ProductModel productInstance) {
    return ListTile(
      leading: Icon(
        Icons.bubble_chart,
        color: UniqueColorGenerator.getRandomPrimaryColor(),
      ),
      title: Text(
        '${productInstance.name} '
        '(PG_ID: ${productInstance.validForPiggyBank})',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        productInstance.getDescription(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ProductDetailPage(productInstance: productInstance)));
      },
    );
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
      itemCount: _products.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _products.length) {
          return _buildProgressIndicator();
        } else {
          return _buildProductTile(_products[index]);
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
