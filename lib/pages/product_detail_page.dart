
import 'package:cyberdindaroloapp/blocs/paginated/paginated_products_bloc.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/pages/products_page.dart';
import 'package:cyberdindaroloapp/validators.dart';
import 'package:cyberdindaroloapp/widgets/piggybank_info_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../alerts.dart';
import '../bloc_provider.dart';

/*
* This file contains the classes responsible to build the product detail info
* view or form view
* ...
* */


class ProductDetailPage extends StatefulWidget {
  final ProductModel productInstance;

  const ProductDetailPage({Key key, @required this.productInstance})
      : super(key: key);

  @override
  _ProductDetailPageState createState() {
    return _ProductDetailPageState();
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Operation _operation;
  PaginatedProductsBloc _paginatedProductsBloc;

  @override
  void initState() {
    _operation = Operation.INFO_VIEW;
    _paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: _operation == Operation.INFO_VIEW
                ? Icon(Icons.edit)
                : Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                if (_operation == Operation.INFO_VIEW)
                  _operation = Operation.EDIT_VIEW;
                else
                  _operation = Operation.INFO_VIEW;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final ConfirmAction confirmation = await asyncConfirmDialog(
                  context,
                  title: "Do you really want to delete this product?",
                  question_message: "You won't be able to rollback once you "
                      "decide to delete a product.");
              if (confirmation != null &&
                  confirmation == ConfirmAction.ACCEPT) {
                final response = await _paginatedProductsBloc.deleteProduct(
                    id: widget.productInstance.id);
                switch (response.status) {
                  case Status.LOADING:
                  // impossible
                    break;
                  case Status.COMPLETED:
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ProductsPage()));
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
            },
          ),
        ],
      ),
      drawer: DefaultDrawer(),
      //backgroundColor: Color(0xFF333333),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: ProductForm(
            productInstance: widget.productInstance,
            edit: _operation == Operation.EDIT_VIEW),
      ),
    );
  }
}

//--------------- EDIT VIEW ---------------------------

class ProductForm extends StatefulWidget {
  final ProductModel productInstance;
  final bool edit;

  const ProductForm({Key key, @required this.productInstance, this.edit: false})
      : super(key: key);

  @override
  _ProductFormState createState() {
    return _ProductFormState();
  }
}

class _ProductFormState extends State<ProductForm> {
  PaginatedProductsBloc _paginatedProductsBloc;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _pNameController;
  TextEditingController _pDescController;

  @override
  void initState() {
    _paginatedProductsBloc = BlocProvider.of<PaginatedProductsBloc>(context);
    _pNameController =
    new TextEditingController(text: widget.productInstance.name);
    _pDescController =
    new TextEditingController(text: widget.productInstance.description);

    super.initState();
  }

  @override
  void dispose() {
    _pNameController.dispose();
    _pDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _pNameController,
              enabled: widget.edit,
              validator: (value) => gpStringValidator(value, 30),
              decoration: InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g. Fish and Chips',
              ),
            ),
            TextFormField(
              controller: _pDescController,
              enabled: widget.edit,
              minLines: 5,
              maxLines: 8,
              validator: (value) => gpEmptyStringValidator(value, 255),
              decoration: InputDecoration(
                labelText: 'Product Description',
                hintText: 'e.g. Hot Dish',
              ),
            ),
            RaisedButton(
              child: Text('Save'),
              onPressed: !widget.edit
                  ? null
                  : () async {
                if (_formKey.currentState.validate()) {
                  final response =
                  await _paginatedProductsBloc.editProduct(
                      oldInstance: widget.productInstance,
                      newName: _pNameController.text,
                      newDesc: _pDescController.text);
                  switch (response.status) {
                    case Status.LOADING:
                    // impossible
                      break;
                    case Status.COMPLETED:
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => ProductsPage()));
                      break;
                    case Status.ERROR:
                      if (response.message
                          .toLowerCase()
                          .contains('token')) {
                        showAlertDialog(
                            context, 'Error', response.message,
                            redirectRoute: '/');
                      } else {
                        showAlertDialog(
                            context, 'Error', response.message);
                      }
                      break;
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
