class User {
  String username;
  User({this.username});
  Map<String, String> toJson() => {
    "username": this.username
  };
  User.fromJson(Map<String, dynamic> data):
      this.username = data["username"];
}