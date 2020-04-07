
import 'package:decimal/decimal.dart';

class StockModel {

  int product;
  String product_name;
  DateTime entry_date;
  int entered_by;
  String entered_by_username;
  Decimal unitary_price;
  int pieces;

	StockModel.fromJson(Map<String, dynamic> map):
		product = map["product"],
		product_name = map["product_name"],
		entry_date = DateTime.parse(map["entry_date"]),
		entered_by = map["entered_by"],
		entered_by_username = map["entered_by_username"],
		unitary_price = Decimal.parse(map["unitary_price"]),
		pieces = map["pieces"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['product'] = product;
		data['product_name'] = product_name;
		data['entry_date'] = entry_date.toString();
		data['entered_by'] = entered_by;
		data['entered_by_username'] = entered_by_username;
		data['unitary_price'] = unitary_price.toString();
		data['pieces'] = pieces;
		return data;
	}
}
