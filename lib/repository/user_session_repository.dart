import 'dart:convert';

import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:cyberdindaroloapp/repository/storage_repository.dart';
import 'package:flutter/material.dart';

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
            UserProfileModel(username: 'unauth', email: 'unauth@email.com', first_name: 'Unauth', last_name: 'Unauth'),
        token: '');
  }

  _getBodyByDifference(
      UserProfileModel oldInstance, UserProfileModel newInstance,
      {String newPwd}) {
    var body = {};
    if (oldInstance.email != newInstance.email) {
      body['email'] = newInstance.email;
    }
    if (oldInstance.first_name != newInstance.first_name) {
      body['first_name'] = newInstance.first_name;
    }
    if (oldInstance.last_name != newInstance.last_name) {
      body['last_name'] = newInstance.last_name;
    }
    if (newPwd != null && newPwd.isNotEmpty) {
      body['passwordA'] = newPwd;
      body['passwordB'] = newPwd;
    }
    return body;
  }

  Future<UserProfileModel> editProfile(
      {@required UserProfileModel oldInstance,
      @required UserProfileModel newInstance,
      String newPwd}) async {
    final headers = await _getAuthHeader();

    final body = _getBodyByDifference(oldInstance, newInstance, newPwd: newPwd);

    if (body.length == 0)
      return oldInstance;

    final response = await _provider.patch("users/${oldInstance.auth_user_id}/",
        headers: headers, body: body);

    return UserProfileModel.fromJson(response);
  }
}
