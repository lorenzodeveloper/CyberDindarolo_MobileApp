import 'package:cyberdindaroloapp/models/paginated_entries_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedEntriesRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  Future<PaginatedEntriesModel> fetchEntries({int page: 1}) async {
    var headers = await _getAuthHeader();
    final response =
    await _provider.get("entries/?page=$page", headers: headers);
    return PaginatedEntriesModel.fromJson(response);
  }

  /*buyProductFromStock({@required int product,
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
    print(response);
    return PurchaseModel.fromJson(response);
  }*/
}
