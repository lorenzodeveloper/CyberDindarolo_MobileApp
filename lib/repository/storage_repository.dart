import 'dart:convert';

import 'package:cyberdindaroloapp/models/user_session_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageRepository {

  final _secure_storage = new FlutterSecureStorage();

  getToken() async {
    final sessionJson = await _secure_storage
        .read(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));

    final stored_token =
        UserSessionModel.fromJson(json.decode(sessionJson))
            .token;

    return stored_token;
  }

  getUserData() async {
    final sessionJson = await _secure_storage
        .read(key: 'sessionJson')
        .timeout(const Duration(seconds: 5));

    return UserSessionModel.fromJson(json.decode(sessionJson)).user_data;
  }


}