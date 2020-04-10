class ProductModel {
  int id;
  String name;
  String description;
  int pieces;
  int validForPiggyBank;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.pieces,
    this.validForPiggyBank,
  });

  String getDescription() {
    return description == null || description.isEmpty
        ? 'No Description.'
        : description;
  }

  ProductModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        description = json["description"],
        pieces = json["pieces"],
        validForPiggyBank = json["valid_for_piggybank"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['pieces'] = pieces;
    data['valid_for_piggybank'] = validForPiggyBank;
    return data;
  }
}
