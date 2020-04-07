import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated_stock_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated_stock_repository.dart';
import 'package:flutter/material.dart';


class PaginatedStockBloc extends BlocBase {
  PaginatedStockRepository _pagStockRepository;
  StreamController _pagStockListController;

  StreamSink<Response<PaginatedStockModel>> get pagStockListSink =>
      _pagStockListController.sink;

  Stream<Response<PaginatedStockModel>> get pagStockListStream =>
      _pagStockListController.stream;

  bool get isClosed => _pagStockListController.isClosed;

  PaginatedStockBloc() {
    _pagStockListController = StreamController<Response<PaginatedStockModel>>.broadcast();
    _pagStockRepository = PaginatedStockRepository();
  }

  fetchPiggyBankStock({int page: 1, @required int piggybank}) async {
    pagStockListSink.add(Response.loading('Getting stock.'));
    try {
      PaginatedStockModel paginatedUsers =
      await _pagStockRepository.fetchPiggyBankStock(page: page, piggybank: piggybank);
      pagStockListSink.add(Response.completed(paginatedUsers));
    } catch (e) {
      pagStockListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _pagStockListController?.close();
  }
}