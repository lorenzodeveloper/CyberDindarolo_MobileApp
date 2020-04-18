import 'dart:async';

import 'package:cyberdindaroloapp/bloc_provider.dart';
import 'package:cyberdindaroloapp/models/paginated/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/Repsonse.dart';
import 'package:cyberdindaroloapp/repository/paginated/paginated_products_repository.dart';
import 'package:flutter/material.dart';

class PaginatedProductsBloc extends BlocBase {
  PaginatedProductsRepository _pagProductsRepository;
  StreamController _pagProductsListController;

  StreamSink<Response<PaginatedProductsModel>> get pagProductsListSink =>
      _pagProductsListController.sink;

  Stream<Response<PaginatedProductsModel>> get pagProductsListStream =>
      _pagProductsListController.stream;

  bool get isClosed => _pagProductsListController.isClosed;

  PaginatedProductsBloc() {
    _pagProductsListController =
        StreamController<Response<PaginatedProductsModel>>.broadcast();
    _pagProductsRepository = PaginatedProductsRepository();
  }

  fetchProducts({int page: 1, String pattern}) async {
    pagProductsListSink.add(Response.loading('Getting products.'));
    try {
      PaginatedProductsModel paginatedProducts = await _pagProductsRepository
          .fetchProducts(page: page, pattern: pattern);
      pagProductsListSink.add(Response.completed(paginatedProducts));
    } catch (e) {
      pagProductsListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Response<ProductModel>> getProduct({@required int id}) async {
    try {
      ProductModel product = await _pagProductsRepository.getProduct(id: id);
      return Response.completed(product);
    } catch (e) {
      return Response.error(e.toString());
    }
  }

  dispose() {
    _pagProductsListController?.close();
  }

  Future<Response<ProductModel>> createProduct(
      {@required String product_name,
      @required String product_description,
      @required int valid_for_piggybank,
      @required int pieces}) async {
    try {
      ProductModel product = await _pagProductsRepository.createProduct(
          product_name: product_name,
          product_description: product_description,
          pieces: pieces,
          valid_for_piggybank: valid_for_piggybank);
      return Response.completed(product);
    } catch (e) {
      return Response.error(e.toString());
    }
  }
}