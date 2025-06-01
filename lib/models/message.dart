class Message {
  final String chatroomId;
  final String sender;
  final String receiver;
  final String text;
  final List<Map<String, String>> specializedTerms;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.chatroomId,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.specializedTerms,
    required this.timestamp,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String myId) {
    List<Map<String, String>> terms = [];

    if (json['specialized_terms'] != null &&
        json['specialized_terms'] != 'none') {
      if (json['specialized_terms'] is List) {
        terms =
            (json['specialized_terms'] as List)
                .map((e) => Map<String, String>.from(e as Map))
                .toList();
      }
    }

    return Message(
      chatroomId: json['chatroom_id'],
      sender: json['from'],
      receiver: json['to'],
      text: json['message'],
      // specializedTerms:
      //     (json['specialized_terms'] as List<dynamic>)
      //         .map((e) => Map<String, String>.from(e as Map))
      //         .toList(),
      specializedTerms: terms,
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['from'] == myId,
    );
  }
}
