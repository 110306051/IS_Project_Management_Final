class Message {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}
