
import 'package:decimal/decimal.dart';

class EntryModel {

  int id;
  int product;
  String product_name;
  int piggybank;
  String piggybank_name;
  DateTime entry_date;
  Decimal entry_price;
  int entered_by;
  String entered_by_username;
  int set_quantity;

	EntryModel.fromJson(Map<String, dynamic> map): 
		id = map["id"],
		product = map["product"],
		product_name = map["product_name"],
		piggybank = map["piggybank"],
		piggybank_name = map["piggybank_name"],
		entry_date = DateTime.parse(map["entry_date"]),
		entry_price = Decimal.parse(map["entry_price"]),
		entered_by = map["entered_by"],
		entered_by_username = map["entered_by_username"],
		set_quantity = map["set_quantity"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['id'] = id;
		data['product'] = product;
		data['product_name'] = product_name;
		data['piggybank'] = piggybank;
		data['piggybank_name'] = piggybank_name;
		data['entry_date'] = entry_date.toString();
		data['entry_price'] = entry_price.toString();
		data['entered_by'] = entered_by;
		data['entered_by_username'] = entered_by_username;
		data['set_quantity'] = set_quantity;
		return data;
	}
}
