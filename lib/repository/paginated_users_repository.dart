import 'package:cyberdindaroloapp/models/paginated_participants_model.dart';
import 'package:cyberdindaroloapp/models/paginated_users_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

class PaginatedUsersRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  Future<PaginatedUsersModel> fetchUsers(
      {int page: 1, String pattern}) async {
    var headers = _getAuthHeader();

    var response;

    if (pattern == null) {
      response = await _provider.get("users/?page=$page", headers: headers);
    } else {
      response = await _provider.get("users/search/$pattern/?page=$page",
          headers: headers);
    }
    return PaginatedUsersModel.fromJson(response);
  }

  Future<PaginatedParticipantsModel> fetchUsersInsidePiggyBank(
      {int page: 1, @required int piggybank}) async {
    var headers = await _getAuthHeader();
    final response = await _provider.get("users/inside/$piggybank/?page=$page",
        headers: headers);
    return PaginatedParticipantsModel.fromJson(response);
  }

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};

  }
}
