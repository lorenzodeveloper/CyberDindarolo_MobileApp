import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated_purchases_model.dart';
import 'package:cyberdindaroloapp/models/purchase_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated_purchases_repository.dart';
import 'package:flutter/material.dart';

class PaginatedPurchasesBloc extends BlocBase {
  PaginatedPurchasesRepository _pagPurchasesRepository;
  StreamController _pagPurchasesListController;

  StreamSink<Response<PaginatedPurchasesModel>> get pagPurchasesListSink =>
      _pagPurchasesListController.sink;

  Stream<Response<PaginatedPurchasesModel>> get pagPurchasesListStream =>
      _pagPurchasesListController.stream;

  bool get isClosed => _pagPurchasesListController.isClosed;

  PaginatedPurchasesBloc() {
    _pagPurchasesListController =
        StreamController<Response<PaginatedPurchasesModel>>.broadcast();
    _pagPurchasesRepository = PaginatedPurchasesRepository();
  }

  fetchPurchases({int page: 1}) async {
    pagPurchasesListSink.add(Response.loading('Getting purchases.'));
    try {
      PaginatedPurchasesModel paginatedUsers =
          await _pagPurchasesRepository.fetchPurchases(page: page);
      pagPurchasesListSink.add(Response.completed(paginatedUsers));
    } catch (e) {
      pagPurchasesListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<PurchaseModel>> buyProductFromStock(
      {@required int product,
      @required int piggybank,
      @required int pieces}) async {
    try {
      PurchaseModel purchaseModel =
          await _pagPurchasesRepository.buyProductFromStock(
              product: product, piggybank: piggybank, pieces: pieces);

      return Response.completed(purchaseModel);
    } catch (e) {
      return Response.error(e.toString());
    }
  }

  dispose() {
    _pagPurchasesListController?.close();
  }
}
