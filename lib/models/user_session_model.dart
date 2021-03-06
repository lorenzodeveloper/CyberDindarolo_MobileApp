import 'package:cyberdindaroloapp/models/user_profile_model.dart';

class UserSessionModel {

  UserProfileModel user_data;
  String token;


	UserSessionModel({this.user_data, this.token});

	UserSessionModel.fromJson(Map<String, dynamic> map):
		user_data = UserProfileModel.fromJson(map["user_data"]),
		token = map["token"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['user_data'] = user_data == null ? null : user_data.toJson();
		data['token'] = token;
		return data;
	}

	String getInitials() {
		return user_data.getInitials();
	}

	@override
  String toString() {
		return "User: ${user_data.toString()}, with token: $token";
  }
}
