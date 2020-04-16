import 'package:cyberdindaroloapp/models/participant_model.dart';

class PaginatedParticipantsModel {

  int count;
	String next;
	String previous;
  List<ParticipantModel> results;

	PaginatedParticipantsModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<ParticipantModel>.from(map["results"].map((it) => ParticipantModel.fromJson(it)));

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
