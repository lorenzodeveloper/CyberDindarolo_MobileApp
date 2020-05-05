import 'package:cyberdindaroloapp/widgets/products_listview_widget.dart';
import 'package:cyberdindaroloapp/widgets/universal_drawer_widget.dart';
import 'package:flutter/material.dart';

/*
* This class is the one responsible for preparing the products list view page
* */


class ProductsPage extends StatefulWidget {
  const ProductsPage({
    Key key,
  }) : super(key: key);

  @override
  _ProductsPageState createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      drawer: DefaultDrawer(highlitedVoice: Voice.PRODUCTS,),
      //backgroundColor: Color(0xFF333333),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: ProductsListViewWidget(),
      ),
    );
  }
}