import 'commons/enums.dart';

final String baseAddress = 'https://c203e9fa2416.ngrok.io';
Map<MessageType, String> messageTypeToString = {
  MessageType.UserMessage: "userMessage",
  MessageType.JoinedRoom: "joinedRoom",
  MessageType.LeftRoom: "leftRoom",
  MessageType.PointsGained: "pointsGained",
  MessageType.InfoMessage: "infoMessage"
};

Map<String, MessageType> stringToMessageType = {
  "userMessage": MessageType.UserMessage,
  "joinedRoom": MessageType.JoinedRoom,
  "leftRoom": MessageType.LeftRoom,
  "pointsGained": MessageType.PointsGained,
  "infoMessage": MessageType.InfoMessage
};

//Socket Events
const String ON_CONNECTION = "connect";
const String CONNECTED = "connected";
const String CREATE_ROOM = "create_room";
const String ROOM_CREATED = "room_created";
const String JOIN_ROOM = "join_room";
const String JOINED_ROOM = "joined_room";
const String NEW_PLAYER = "new_player";
const String LEAVE_ROOM = "leave_room";
const String LEFT_ROOM = "left_room";
const String CLOSE_ROOM = "closr_room";
const String DRAWING = "drawing";
const String CLEAR_DRAWING = "clear_drawing";
const String NEW_MESSAGE = "new_message";
const String NEXT_TURN = "next_turn";
const String YOUR_TURN = "your_turn";
const String WORD_SELECTED = "word_selected";
const String TURN_ENDED = "turn_ended";
const String START_GAME = "start_game";
const String GAME_STARTED = "game_started";
const String NEW_STATUS = "new_status";
const String START_DRAWING = "start_drawing";
const String ADD_POINTS = "add_points";
const String END_TURN = "end_turn";
const String SKIP_TURN = "skip_turn";
const String END_GAME = "end_game";
const String CHANGE_ADMIN = "change_admin";
const String DISCONNECT = "disconnect";
const String CONNECT_ERROR = "connect_error";
