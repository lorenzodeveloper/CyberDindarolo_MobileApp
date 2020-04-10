import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated_entries_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated_entries_repository.dart';
import 'package:flutter/material.dart';

class PaginatedEntriesBloc extends BlocBase {
  PaginatedEntriesRepository _pagEntriesRepository;
  StreamController _pagEntriesListController;

  StreamSink<Response<PaginatedEntriesModel>> get pagEntriesListSink =>
      _pagEntriesListController.sink;

  Stream<Response<PaginatedEntriesModel>> get pagEntriesListStream =>
      _pagEntriesListController.stream;

  bool get isClosed => _pagEntriesListController.isClosed;

  PaginatedEntriesBloc() {
    _pagEntriesListController =
        StreamController<Response<PaginatedEntriesModel>>.broadcast();
    _pagEntriesRepository = PaginatedEntriesRepository();
  }

  fetchEntries({int page: 1}) async {
    pagEntriesListSink.add(Response.loading('Getting entries.'));
    try {
      PaginatedEntriesModel paginatedEntriesModel =
          await _pagEntriesRepository.fetchEntries(page: page);
      pagEntriesListSink.add(Response.completed(paginatedEntriesModel));
    } catch (e) {
      pagEntriesListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

 /* Future<Response<PurchaseModel>> buyProductFromStock(
      {@required int product,
      @required int piggybank,
      @required int pieces}) async {
    try {
      PurchaseModel purchaseModel =
          await _pagEntriesRepository.buyProductFromStock(
              product: product, piggybank: piggybank, pieces: pieces);

      return Response.completed(purchaseModel);
    } catch (e) {
      return Response.error(e.toString());
    }
  }*/

  dispose() {
    _pagEntriesListController?.close();
  }
}
