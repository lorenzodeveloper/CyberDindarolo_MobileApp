import 'package:cyberdindaroloapp/models/user_profile_model.dart';

class PaginatedUsersModel {

  int count;
  String next;
  String previous;
  List<UserProfileModel> results;

	PaginatedUsersModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<UserProfileModel>.from(map["results"].map((it) => UserProfileModel.fromJson(it)));

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['count'] = count;
		data['next'] = next;
		data['previous'] = previous;
		data['results'] = results != null ? 
			this.results.map((v) => v.toJson()).toList()
			: null;
		return data;
	}
}
