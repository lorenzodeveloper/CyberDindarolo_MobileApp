import 'package:cyberdindaroloapp/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class SessionInfo extends ChangeNotifier {

  UserProfileModel user_data;
  String token;

  SessionInfo.fromJson(Map<String, dynamic> map):
        user_data = UserProfileModel.fromJson(map["user_data"]),
        token = map["token"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_data'] = user_data == null ? null : user_data.toJson();
    data['token'] = token;
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return user_data.toString() + " " + token;
  }
}
