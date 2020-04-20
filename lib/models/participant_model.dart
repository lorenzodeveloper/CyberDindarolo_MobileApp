import 'package:decimal/decimal.dart';

class ParticipantModel {

  int auth_user_id;
  String username;
  String first_name;
  String last_name;
  Decimal credit;

	ParticipantModel.fromJson(Map<String, dynamic> map):
		auth_user_id = map["participant"],
		username = map["username"],
		first_name = map["first_name"],
		last_name = map["last_name"],
		credit = Decimal.parse(map["credit"]);

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['participant'] = auth_user_id;
		data['username'] = username;
		data['first_name'] = first_name;
		data['last_name'] = last_name;
		data['credit'] = credit.toString();
		return data;
	}
}
