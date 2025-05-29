import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTime;
  final bool showAvatar;
  final String avatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showTime,
    required this.showAvatar,
    required this.avatar,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour;
    return '$formattedHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // 對方的頭像或空間占位
              if (!message.isMe)
                SizedBox(
                  width: 40,
                  child:
                      showAvatar
                          ? Align(
                            alignment: Alignment.bottomCenter,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(avatar),
                            ),
                          )
                          : null,
                ),
              SizedBox(width: 10),
              // 氣泡訊息
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.45,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.isMe ? Color(0xfffd999a) : Color(0xffe3dede),
                  borderRadius: BorderRadius.only(
                    bottomRight:
                        message.isMe ? Radius.circular(0) : Radius.circular(10),
                    bottomLeft:
                        message.isMe ? Radius.circular(10) : Radius.circular(0),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.8),
                  //     spreadRadius: 2,
                  //     blurRadius: 5,
                  //     offset: Offset(2.5, 2.5),
                  //   ),
                  // ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontFamily: 'Outfit',

                    color:
                        message.isMe
                            ? Color(0xfff4f7f7)
                            : Color.fromARGB(255, 29, 39, 48),
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          // 發送時間
          if (showTime)
            Padding(
              padding: EdgeInsets.only(
                left: !message.isMe && showAvatar ? 48.0 : 0.0, // 時間對齊訊息左邊
                right: message.isMe ? 0.0 : 0.0,
              ),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
