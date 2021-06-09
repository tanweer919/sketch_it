class PublicRoom {
  String name;
  String roomId;
  int visiblity;
  int active;
  String adminUsername;
  PublicRoom({this.name, this.roomId, this.visiblity, this.active, this.adminUsername});
  PublicRoom.fromJson(Map<String, dynamic> parsedJson):
    name = parsedJson["name"],
    roomId = parsedJson["roomId"],
    visiblity = parsedJson["visiblity"],
    active = parsedJson["active"],
    adminUsername = parsedJson["admin"]["user"]["username"];
}