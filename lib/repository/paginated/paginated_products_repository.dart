import 'package:cyberdindaroloapp/models/paginated/paginated_products_model.dart';
import 'package:cyberdindaroloapp/models/product_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedProductsRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedProductsModel> fetchProducts(
      {int page: 1, String pattern}) async {
    var headers = await _getAuthHeader();

    var response;

    if (pattern == null || pattern.isEmpty) {
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

  Future<ProductModel> getProduct({@required int id}) async {
    var headers = await _getAuthHeader();

    final response = await _provider.get("products/$id/", headers: headers);

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> createProduct(
      {@required String product_name,
      @required String product_description,
      @required int valid_for_piggybank,
      @required int pieces}) async {
    final headers = await _getAuthHeader();

    var body = {
      'name': product_name,
      'description': product_description,
      'valid_for_piggybank': valid_for_piggybank.toString(),
      'pieces': pieces.toString(),
    };

    final response =
        await _provider.post("products/", headers: headers, body: body);

    return ProductModel.fromJson(response);
  }

  Future<bool> deleteProduct({@required int id}) async {
    final headers = await _getAuthHeader();

    final response = await _provider.delete("products/$id/", headers: headers);

    return response['success'];
  }

  Future<ProductModel> editProduct(
      {@required ProductModel oldInstance,
      @required String newName,
      @required String newDesc}) async {
    final headers = await _getAuthHeader();

    var body = {};
    if (newName != oldInstance.name) body['name'] = newName;
    if (newDesc != '') body['description'] = newDesc;

    if (body.length == 0) return oldInstance;

    final response = await _provider.patch("products/${oldInstance.id}/",
        headers: headers, body: body);

    return ProductModel.fromJson(response);
  }
}
