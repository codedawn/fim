class Message{
  MessageType messageType;
  final msg;

  Message(this.messageType, this.msg);
}
enum MessageType{
  TEXT_MESSAGE,
  IMAGE_MESSAGE,
}