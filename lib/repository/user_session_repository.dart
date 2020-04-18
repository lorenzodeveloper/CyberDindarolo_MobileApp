import 'dart:convert';

import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';

class UserSessionRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  StorageRepository _storageRepository = StorageRepository();

  _getAuthHeader() async {
    final stored_token = await _storageRepository.getToken();

    return {'Authorization': 'Token $stored_token'};
  }

  Future<UserSessionModel> login({String username, String password}) async {
    var authBody;
    var pwd;

    if (username != null && password != null) {
      authBody = {'username': username, 'password': password};
      pwd = password;
    } else {
      final stored_pwd = await _storageRepository.getPassword();

      final stored_username = (await _storageRepository.getUserData()).username;

      authBody = {'username': stored_username, 'password': stored_pwd};
      pwd = stored_pwd;
    }

    final response = await _provider.post('login/', body: authBody);

    _storageRepository.persistUserSession(json.encode(response), pwd);

    return UserSessionModel.fromJson(response);
  }

  Future<UserSessionModel> fetchUserSession() async {
    return await _storageRepository.getUserSessionModel();
  }

  Future<UserSessionModel> logout() async {
    final headers = await _getAuthHeader();

    final response = await _provider.get("logout/", headers: headers);

    await _storageRepository.deleteUserSession();

    return UserSessionModel(
        user_data:
            UserProfileModel(username: 'unauth', email: 'unauth@email.com'),
        token: '');
  }
}
