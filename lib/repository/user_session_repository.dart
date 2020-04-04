import 'dart:convert';

import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:cyberdindaroloapp/networking/ApiProvider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSessionRepository {
  CyberDindaroloAPIv1Provider _provider = CyberDindaroloAPIv1Provider();
  final _secure_storage = new FlutterSecureStorage();

  Future<UserSessionModel> login({String username, String password}) async {
    var authBody;
    var pwd;

    if (username != null && password != null) {
      authBody = {'username': username, 'password': password};
      pwd = password;
    } else {
      final sessionJson = await _secure_storage
          .read(key: 'sessionJson')
          .timeout(const Duration(seconds: 5));

      final stored_pwd = await _secure_storage
          .read(key: 'password')
          .timeout(const Duration(seconds: 5));

      if (sessionJson == null || stored_pwd == null)
        throw Exception("Credentials not stored");

      final stored_username =
          UserSessionModel.fromJson(json.decode(sessionJson))
              .user_data
              .username;

      authBody = {'username': stored_username, 'password': stored_pwd};
      pwd = stored_pwd;
    }

    final response = await _provider.post('login/', body: authBody);
    _persistUserSession(json.encode(response), pwd);

    return UserSessionModel.fromJson(response);
  }

  _persistUserSession(userSessionJson, String password) async {
    await _secure_storage
        .write(key: 'sessionJson', value: userSessionJson)
        .timeout(const Duration(seconds: 5));
    await _secure_storage
        .write(key: 'password', value: password)
        .timeout(const Duration(seconds: 5));
  }

  Future<UserSessionModel> fetchUserSession() async {
    final sessionJson = await _secure_storage
        .read(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));

    if (sessionJson == null)
      throw Exception("Credentials not stored");

    return UserSessionModel.fromJson(json.decode(sessionJson));
  }

  Future<UserSessionModel> logout() async {
     await _secure_storage
        .delete(key: 'token')
        .timeout(const Duration(seconds: 5));

    return UserSessionModel(user_data: UserProfileModel(username:'unauth',
    email: 'unauth@email.com'), token: '');
  }
}
