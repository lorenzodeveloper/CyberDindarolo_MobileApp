import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/entry_model.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_entries_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated/paginated_entries_repository.dart';
import 'package:decimal/decimal.dart';
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

  Future<Response<EntryModel>> insertEntry(
      {@required int piggybank_id,
      @required int product_id,
      @required int set_quantity,
      @required Decimal single_set_price}) async {
    try {
      EntryModel entryModel = await _pagEntriesRepository.insertEntry(
        piggybank_id: piggybank_id,
        product_id: product_id,
        set_quantity: set_quantity,
        single_set_price: single_set_price,
      );

      return Response.completed(entryModel);
    } catch (e) {
      return Response.error(e.toString());
    }
  }

  Future<Response<bool>> deleteEntry({@required int id}) async {
    try {
      final bool success = await _pagEntriesRepository.deleteEntry(id: id);

      return Response.completed(success);
    } catch (e) {
      print(e);
      return Response.error(e.toString());
    }
  }
}
