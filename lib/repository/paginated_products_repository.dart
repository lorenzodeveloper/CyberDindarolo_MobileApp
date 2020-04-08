
import 'package:cyberdindaroloapp/models/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedProductsRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedProductsModel> fetchProducts(
      {int page: 1, String pattern}) async {
    var headers = _getAuthHeader();

    var response;

    if (pattern == null) {
      response = await _provider.get("products/?page=$page", headers: headers);
    } else {
      response = await _provider.get("products/search/$pattern/?page=$page",
          headers: headers);
    }
    return PaginatedProductsModel.fromJson(response);
  }

/*  Future<PaginatedProductsModel> fetchUsersInsidePiggyBank(
      {int page: 1, @required int piggybank}) async {
    var headers = await _getAuthHeader();
    final response = await _provider.get(".../$piggybank/?page=$page",
        headers: headers);
    return PaginatedProductsModel.fromJson(response);
  }*/

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};

  }

  Future<ProductModel> getProduct({int id}) async {
    var headers = await _getAuthHeader();

    final response = await _provider.get("products/$id/", headers: headers);

    return ProductModel.fromJson(response);
  }
}
