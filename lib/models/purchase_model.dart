
import 'package:decimal/decimal.dart';

class PurchaseModel {

  int id;
  int product;
  String product_name;
  int piggybank;
  String piggybank_name;
  int purchaser;
  String purchaser_username;
  DateTime purchase_date;
  Decimal unitary_purchase_price;
  int pieces;

	PurchaseModel.fromJson(Map<String, dynamic> map): 
		id = map["id"],
		product = map["product"],
		product_name = map["product_name"],
		piggybank = map["piggybank"],
		piggybank_name = map["piggybank_name"],
		purchaser = map["purchaser"],
		purchaser_username = map["purchaser_username"],
		purchase_date = DateTime.parse(map["purchase_date"]),
		unitary_purchase_price = Decimal.parse(map["unitary_purchase_price"]),
		pieces = map["pieces"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['id'] = id;
		data['product'] = product;
		data['product_name'] = product_name;
		data['piggybank'] = piggybank;
		data['piggybank_name'] = piggybank_name;
		data['purchaser'] = purchaser;
		data['purchaser_username'] = purchaser_username;
		data['purchase_date'] = purchase_date.toString();
		data['unitary_purchase_price'] = unitary_purchase_price.toString();
		data['pieces'] = pieces;
		return data;
	}
}
