enum DrawAction {Draw, ClearDraw}
enum PlayerAction {Add, Remove}
enum MessageType {UserMessage, JoinedRoom, LeftRoom, PointsGained, InfoMessage}
enum GameStatus {NotStarted, Started, Over}
enum StatusAction {RoomStatusChange, GameStatusChange}
enum GameAction {JoinGame, StartTurn, EndTurn, SkipTurn, WordSelection, StartDrawing, AddPoints, EndGame, ChangeAdmin}