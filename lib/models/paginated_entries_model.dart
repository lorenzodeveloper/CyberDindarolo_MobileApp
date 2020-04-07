import 'package:cyberdindaroloapp/models/entry_model.dart';

class PaginatedEntriesModel {

  int count;
  String next;
	String previous;
  List<EntryModel> results;

	PaginatedEntriesModel.fromJson(Map<String, dynamic> map): 
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<EntryModel>.from(map["results"].map((it) => EntryModel.fromJson(it)));

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
