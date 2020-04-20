import 'package:cyberdindaroloapp/models/invitation_model.dart';

class PaginatedInvitationsModel {

  int count;
  Object next;
  Object previous;
  List<InvitationModel> invitations;

	PaginatedInvitationsModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		invitations = List<InvitationModel>.from(map["results"].map((it) => InvitationModel.fromJson(it)));

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['count'] = count;
		data['next'] = next;
		data['previous'] = previous;
		data['results'] = invitations != null ?
			this.invitations.map((v) => v.toJson()).toList()
			: null;
		return data;
	}
}
