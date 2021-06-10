class PublicRoom {
  String name;
  String roomId;
  int visiblity;
  int active;
  String adminUsername;
  int noOfPlayers;
  int maxPlayers;
  PublicRoom(
      {this.name,
      this.roomId,
      this.visiblity,
      this.active,
      this.adminUsername,
      this.noOfPlayers,
      this.maxPlayers});
  PublicRoom.fromJson(Map<String, dynamic> parsedJson)
      : name = parsedJson["name"],
        roomId = parsedJson["roomId"],
        visiblity = parsedJson["visiblity"],
        active = parsedJson["active"],
        adminUsername = parsedJson["admin"]["user"]["username"],
        noOfPlayers = parsedJson["currentPlayers"],
        maxPlayers = parsedJson["maxPlayers"];
}
