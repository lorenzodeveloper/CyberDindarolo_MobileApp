import 'dart:convert';

import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageRepository {

  final _secure_storage = new FlutterSecureStorage();

  Future<String> getToken() async {
    final sessionJson = await _secure_storage
        .read(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));

    final stored_token =
        UserSessionModel.fromJson(json.decode(sessionJson))
            .token;

    return stored_token;
  }

  Future<UserSessionModel> getUserSessionModel() async {
    final sessionJson = await _secure_storage
        .read(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));

    if (sessionJson == null)
      throw Exception("Credentials not stored");

    return UserSessionModel.fromJson(json.decode(sessionJson));
  }

  Future<UserProfileModel> getUserData() async {

    return (await getUserSessionModel()).user_data;
  }

  Future<String> getPassword() async {
    final stored_pwd = await _secure_storage
        .read(key: 'password')
        .timeout(const Duration(seconds: 5));

    if (stored_pwd == null)
      throw Exception("Credentials not stored");

    return stored_pwd;
  }

  persistUserSession(userSessionJson, String password) async {
    await _secure_storage
        .write(key: 'sessionJson', value: userSessionJson)
        .timeout(const Duration(seconds: 5));
    await _secure_storage
        .write(key: 'password', value: password)
        .timeout(const Duration(seconds: 5));
  }

  deleteUserSession() async {
    await _secure_storage
        .delete(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));
  }


}