import 'package:cyberdindaroloapp/models/stock_model.dart';

class PaginatedStockModel {

  int count;
	String next;
	String previous;
  List<StockModel> results;

	PaginatedStockModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<StockModel>.from(map["results"].map((it) => StockModel.fromJson(it)));

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
