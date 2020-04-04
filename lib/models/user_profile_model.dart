class UserProfileModel {
  // api fields = ['auth_user_id', 'username', 'email', 'first_name',
  // 'last_name']
  int auth_user_id;
  String username;
  String email;
  String first_name;
  String last_name;

  UserProfileModel.fromJson(Map<String, dynamic> map):
        auth_user_id = map["auth_user_id"],
        username = map["username"],
        email = map["email"],
        first_name = map["first_name"],
        last_name = map["last_name"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_user_id'] = auth_user_id;
    data['username'] = username;
    data['email'] = email;
    data['first_name'] = first_name;
    data['last_name'] = last_name;
    return data;
  }

  @override
  String toString() {
    return "User #$auth_user_id $username";
  }
}
