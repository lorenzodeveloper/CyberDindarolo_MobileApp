import 'package:cyberdindaroloapp/models/piggybank_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PiggyBankRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  Future<PiggyBankModel> fetchPiggyBankData(int id) async {
    final headers = await _getAuthHeader();

    final response = await _provider.get("piggybanks/$id/", headers: headers);
    return PiggyBankModel.fromJson(response);
  }

  Future<bool> closePiggyBank(int id) async {
    final headers = await _getAuthHeader();

    final response =
        await _provider.delete("piggybanks/$id/", headers: headers);

    return response['success'];
  }

  Future<PiggyBankModel> updatePiggyBank(
      {@required int id,
      @required String newName,
      @required String newDescription}) async {
    final headers = await _getAuthHeader();

    var body = {
      'pb_name': newName,
      'pb_description': newDescription,
    };

    final response =
        await _provider.patch("piggybanks/$id/", headers: headers, body: body);

    return PiggyBankModel.fromJson(response);
  }

  Future<PiggyBankModel> createPiggyBank(
      {@required String name, @required String description}) async {
    final headers = await _getAuthHeader();

    var body = {
      'pb_name': name,
      'pb_description': description,
    };

    final response =
        await _provider.post("piggybanks/", headers: headers, body: body);

    return PiggyBankModel.fromJson(response);
  }
}
