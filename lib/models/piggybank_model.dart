
class PaginatedPiggyBanksModel {
  int count;
  Object next;
  Object previous;
  List<PiggyBankModel> results;

  PaginatedPiggyBanksModel.fromJson(Map<String, dynamic> map)
      : count = map["count"],
        next = map["next"],
        previous = map["previous"],
        results = List<PiggyBankModel>.from(
            map["results"].map((it) => PiggyBankModel.fromJson(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = count;
    data['next'] = next;
    data['previous'] = previous;
    data['results'] =
        results != null ? this.results.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

class PiggyBankModel {
  int id;
  String pbName;
  String pbDescription;
  int createdBy;
  String createdByUsername;
  bool closed;

  PiggyBankModel.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        pbName = map["pb_name"],
        pbDescription = map["pb_description"],
        createdBy = map["created_by"],
        createdByUsername = map["created_by_username"],
        closed = map["closed"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['pb_name'] = pbName;
    data['pb_description'] = pbDescription;
    data['created_by'] = createdBy;
    data['created_by_username'] = createdByUsername;
    data['closed'] = closed;
    return data;
  }

  @override
  String toString() {
    return 'PiggyBank #$id \'$pbName\' created by $createdByUsername.';
  }
}
