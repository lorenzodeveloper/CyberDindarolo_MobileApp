import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class PaginatedPiggyBanksRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  Future<PaginatedPiggyBanksModel> fetchPiggyBanksData({int page: 1}) async {
    final headers = await _getAuthHeader();

    final response =
        await _provider.get("piggybanks/?page=$page", headers: headers);
    return PaginatedPiggyBanksModel.fromJson(response);
  }

  Future<Decimal> getCredit({@required int piggybank}) async {
    final headers = await _getAuthHeader();

    final response =
        await _provider.get("credit/$piggybank/", headers: headers);
    return Decimal.parse(response['credit'].toString());
  }
}
