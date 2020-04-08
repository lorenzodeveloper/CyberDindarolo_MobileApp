import 'package:cyberdindaroloapp/models/product_model.dart';

class PaginatedProductsModel {

  int count;
  String next;
  String previous;
  List<ProductModel> results;

	PaginatedProductsModel.fromJson(Map<String, dynamic> map):
		count = map["count"],
		next = map["next"],
		previous = map["previous"],
		results = List<ProductModel>.from(map["results"].map((it) => ProductModel.fromJson(it)));

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
