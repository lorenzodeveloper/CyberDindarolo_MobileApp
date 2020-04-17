import 'package:cyberdindaroloapp/blocs/paginated/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductsDialog extends StatefulWidget {
  @override
  ProductsDialogState createState() {
    return ProductsDialogState();
  }
}

class ProductsDialogState extends State<ProductsDialog> {
  int currentPage = 1;
  int nextPage = -1;
  int prevPage = -1;

  PaginatedProductsBloc _paginatedProductsBloc;
  TextEditingController _searchFieldController;

  String _errorMessage;

  @override
  void initState() {
    _paginatedProductsBloc = new PaginatedProductsBloc();
    _searchFieldController = new TextEditingController();
    _paginatedProductsBloc.fetchProducts();
    super.initState();
  }

  @override
  void dispose() {
    _paginatedProductsBloc.dispose();
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
                currentPage = 1;
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
          onPressed: prevPage <= 0
              ? null
              : () {
                  currentPage--;
                  _paginatedProductsBloc.fetchProducts(
                      pattern: _searchFieldController.text, page: prevPage);
                },
        ),
        RaisedButton(
          child: Text('Next'),
          onPressed: nextPage <= 0
              ? null
              : () {
                  currentPage++;
                  _paginatedProductsBloc.fetchProducts(
                      pattern: _searchFieldController.text, page: nextPage);
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
                  prevPage = -1;
                } else {
                  prevPage = currentPage - 1;
                }

                if (snapshot.data.data.next == null) {
                  nextPage = -1;
                } else {
                  nextPage = currentPage + 1;
                }

                return SimpleDialog(
                  title: const Text('Select a Product'),
                  // Generate list of product
                  children: [
                    _getSearchTextField(),
                    ListView.builder(
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
