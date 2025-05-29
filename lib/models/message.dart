// class Message {
//   final String sender;
//   final String text;
//   final DateTime timestamp;
//   final bool isMe;

//   Message({
//     required this.sender,
//     required this.text,
//     required this.timestamp,
//     required this.isMe,
//   });
// }
class Message {
  final String chatroomId;
  final String sender;
  final String receiver;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.chatroomId,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String myId) {
    return Message(
      chatroomId: json['chatroom_id'],
      sender: json['from'],
      receiver: json['to'],
      text: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['from'] == myId,
    );
  }
}
