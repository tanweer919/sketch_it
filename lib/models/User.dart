class User {
  String username;
  String email;
  String profilePicUrl;
  User({this.username, this.email, this.profilePicUrl});
  Map<String, String> toJson() => {
    "username": this.username,
  };
  User.fromJson(Map<String, dynamic> data):
      this.username = data["username"];
}