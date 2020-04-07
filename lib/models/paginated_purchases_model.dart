import 'package:cyberdindaroloapp/models/purchase_model.dart';

class PaginatedPurchasesModel {

  int count;
  String next;
  String previous;
  List<PurchaseModel> results;

	PaginatedPurchasesModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<PurchaseModel>.from(map["results"].map((it) => PurchaseModel.fromJson(it)));

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
