import 'package:cyberdindaroloapp/models/invitation_model.dart';

class PaginatedInvitationsModel {

  int count;
  Object next;
  Object previous;
  List<InvitationModel> results;

	PaginatedInvitationsModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<InvitationModel>.from(map["results"].map((it) => InvitationModel.fromJson(it)));

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
