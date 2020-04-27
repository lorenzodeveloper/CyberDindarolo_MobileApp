import 'package:cyberdindaroloapp/models/paginated/paginated_purchases_model.dart';
import 'package:cyberdindaroloapp/models/purchase_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedPurchasesRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedPurchasesModel> fetchPurchases({int page: 1}) async {
    var headers = await _getAuthHeader();
    final response =
        await _provider.get("purchases/?page=$page", headers: headers);
    return PaginatedPurchasesModel.fromJson(response);
  }

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  buyProductFromStock(
      {@required int product,
      @required int piggybank,
      @required int pieces}) async {
    var headers = await _getAuthHeader();
    var requestBody = {
      'product': product.toString(),
      'piggybank': piggybank.toString(),
      'pieces': pieces.toString()
    };

    final response =
        await _provider.post("purchases/", headers: headers, body: requestBody);
    return PurchaseModel.fromJson(response);
  }

  Future<bool> deletePurchase({int id}) async {
    final headers = await _getAuthHeader();

    final response = await _provider.delete("purchases/$id/", headers: headers);

    return response['success'];
  }
}
