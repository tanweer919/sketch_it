import 'package:flutter/material.dart';
import '../models/User.dart';
import '../models/PublicRoom.dart';
import '../services/RoomService.dart';
import '../services/GetItLocator.dart';
class AppProvider extends ChangeNotifier {
  User _currentUser;
  List<PublicRoom> _publicRooms;
  List<bool> _isRoomJoiningInProgress;
  RoomService _roomService = locator<RoomService>();
  AppProvider(this._currentUser, this._publicRooms);

  User get currentUser => _currentUser;

  List<PublicRoom> get publicRooms => _publicRooms;

  List<bool> get isRoomJoiningInProgress => _isRoomJoiningInProgress;

  set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }


  set publicRooms(List<PublicRoom> rooms) {
    _publicRooms = rooms;
    notifyListeners();
  }

  void modifyRoomProgress({int index, bool value}) {
    List<bool> modifiedValue = [..._isRoomJoiningInProgress];
    modifiedValue[index] = value;
    _isRoomJoiningInProgress = modifiedValue;
    notifyListeners();
  }

  Future<void> loadPublicRooms() async{
    _publicRooms = await _roomService.fetchAllPublicRooms();
    _isRoomJoiningInProgress = List.filled(_publicRooms.length, false);
    notifyListeners();
  }
}