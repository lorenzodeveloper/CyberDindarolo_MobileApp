import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/blocs/paginated/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductsDialog extends StatefulWidget {
  @override
  _ProductsDialogState createState() {
    return _ProductsDialogState();
  }
}

class _ProductsDialogState extends State<ProductsDialog> {
  int _currentPage = 1;
  int _nextPage = -1;
  int _prevPage = -1;

  PaginatedProductsBloc _paginatedProductsBloc;
  TextEditingController _searchFieldController;

  String _errorMessage;

  @override
  void initState() {
    _paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);
    _searchFieldController = new TextEditingController();
    _paginatedProductsBloc.fetchProducts();
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  Row _getSearchTextField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Search textField
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchFieldController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'Search for a product (e.g. \'Chicken\')'),
              onEditingComplete: () {
                _currentPage = 1;
                _paginatedProductsBloc.fetchProducts(
                    pattern: _searchFieldController.text);
              },
            ),
          ),
        )
      ],
    );
  }

  Row _getFootersButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text('Prev'),
          onPressed: _prevPage <= 0
              ? null
              : () {
                  _currentPage--;
                  _paginatedProductsBloc.fetchProducts(
                      pattern: _searchFieldController.text, page: _prevPage);
                },
        ),
        RaisedButton(
          child: Text('Next'),
          onPressed: _nextPage <= 0
              ? null
              : () {
                  _currentPage++;
                  _paginatedProductsBloc.fetchProducts(
                      pattern: _searchFieldController.text, page: _nextPage);
                },
        ),
      ],
    );
  }

  ListTile _getProductTile(ProductModel productInstance) {
    return ListTile(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<PaginatedProductsModel>>(
        stream: _paginatedProductsBloc.pagProductsListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return CircularProgressIndicator();
                break;
              case Status.COMPLETED:
                // Next page and prevoius page setting..
                if (snapshot.data.data.previous == null) {
                  _prevPage = -1;
                } else {
                  _prevPage = _currentPage - 1;
                }

                if (snapshot.data.data.next == null) {
                  _nextPage = -1;
                } else {
                  _nextPage = _currentPage + 1;
                }

                return SimpleDialog(
                  title: const Text('Select a Product'),
                  // Generate list of product
                  children: [
                    _getSearchTextField(),
                    Container(
                      width: double.maxFinite,
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: snapshot.data.data.results.length + 1,
                          itemBuilder: (context, index) {
                            // First tile is reserved for 'add new product'
                            if (index != 0) {
                              ProductModel productInstance =
                                  snapshot.data.data.results[index - 1];
                              return SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context,
                                      Response.completed(productInstance));
                                },
                                child: _getProductTile(productInstance),
                              );
                            } else {
                              return SimpleDialogOption(
                                  onPressed: () {
                                    // -1 = Insert new product,
                                    // null = operation canceled
                                    Navigator.pop(
                                        context, Response.completed(null));
                                  },
                                  child: ListTile(
                                    title: Text('Add new product'),
                                    leading: Icon(Icons.add),
                                  ));
                            }
                          }),
                    ),
                    _getFootersButtons()
                  ],
                );
                break;
              case Status.ERROR:
                _errorMessage = snapshot.data.message;

                return Error(
                  errorButtonText: 'Error',
                  errorMessage: _errorMessage,
                  onRetryPressed: () {
                    Navigator.pop(context, Response.error(_errorMessage));
                  },
                );
                break;
            }
          }
          return Container();
        });
  }
}
