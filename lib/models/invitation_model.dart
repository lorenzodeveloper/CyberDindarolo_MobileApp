
class InvitationModel {
  int id;
  int inviter;
  String inviter_username;
  int invited;
  String invited_username;
  DateTime invitation_date;
  int piggybank;
  String piggybank_name;

	InvitationModel.fromJson(Map<String, dynamic> map): 
		id = map["id"],
		inviter = map["inviter"],
		inviter_username = map["inviter_username"],
		invited = map["invited"],
		invited_username = map["invited_username"],
		invitation_date = DateTime.parse(map["invitation_date"]),
		piggybank = map["piggybank"],
		piggybank_name = map["piggybank_name"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['id'] = id;
		data['inviter'] = inviter;
		data['inviter_username'] = inviter_username;
		data['invited'] = invited;
		data['invited_username'] = invited_username;
		data['invitation_date'] = invitation_date.toString();
		data['piggybank'] = piggybank;
		data['piggybank_name'] = piggybank_name;
		return data;
	}
}
