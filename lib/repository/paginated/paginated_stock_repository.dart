import 'package:cyberdindaroloapp/models/paginated/paginated_stock_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedStockRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedStockModel> fetchPiggyBankStock(
      {int page: 1, @required int piggybank}) async {
    var headers = await _getAuthHeader();
    final response = await _provider.get("stock/$piggybank/?page=$page",
        headers: headers);
    return PaginatedStockModel.fromJson(response);
  }

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }
}
