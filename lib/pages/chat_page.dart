import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'chat_list_page.dart';
import '../services/socket_service.dart';
import 'dart:convert';
import '../services/token_service.dart';
import '../services/api_service.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String chatroomId;
  final String avatar;
  final String myLanguage;
  final String otherLanguage;

  const ChatPage({
    super.key,
    required this.name,
    required this.avatar,
    required this.chatroomId,
    required this.myLanguage,
    required this.otherLanguage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final socketService = SocketService(); //* SocketService 用來處理 WebSocket 連線

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // final username = ApiService.globalUsername;

  bool _isListening = false;

  //! initState
  @override
  void initState() {
    super.initState();

    fetchMessages();

    TokenService.getUsername().then((value) {
      if (value != null) {
        socketService.onReceiveMessage((data) {
          final message = Message.fromJson(data, value);
          setState(() {
            _messages.add(message);
            _scrollToBottom();
          });
          _scrollToBottom();
        });
      }
    });
  }

  //! _receiveMessage
  Future<void> fetchMessages() async {
    final messages = await ApiService.fetchMessages(
      username: ApiService.globalUsername,
      chatroomId: widget.chatroomId,
    );

    setState(() {
      _messages.clear();
      _messages.addAll(messages);
    });

    // 等 ListView rebuild 完成再捲動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    // 50ms後再補一次，確保render完成
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    // Future.delayed(Duration(milliseconds: 500), () {
    //   _scrollToBottom();
    // });
  }

  //! dispose
  @override
  void dispose() {
    socketService.socket.off('receive_message'); // 這樣離開時會移除 listener
    super.dispose();
  }

  //! _sendMessage
  void _sendMessage() async {
    if (_inputController.text.trim().isEmpty) return;

    final text = _inputController.text.trim();

    final messagePayload = {
      'chatroom_id': widget.chatroomId,
      'sender_id': ApiService.globalUsername, // 假設發送者是自己
      'receiver_id': widget.name, // 對方的 ID
      'text': text,
      'sender_lang': widget.myLanguage, // 自己的語言
      'receiver_lang': widget.otherLanguage, // 對方的語言
    };

    socketService.sendMessage(messagePayload);

    // 清空輸入框
    _inputController.clear();
    _scrollToBottom();
  }

  //! _scrollToBottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 1000,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //! _formatDateLabel
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return 'Today, ${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      // 回傳星期幾
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return '${weekdays[messageDate.weekday - 1]}, ${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } else if (difference < 14) {
      return 'Last week';
    } else {
      // 超過兩週就顯示年月日
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  //! build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 39, 48),
      body: SafeArea(
        child: Column(
          children: [
            // 頂部 Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 20,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Color(0xfff4f7f7),
                    ),
                    onPressed: () {
                      dispose();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChatListPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(widget.avatar),
                  ),
                  const SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          color: Color(0xfff4f7f7),
                        ),
                      ),

                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xfff4f7f7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // 中間訊息區 填滿剩下空間
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Color(0xfff4f7f7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 📌 日期列
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _formatDateLabel(DateTime.now()), // 👉 呼叫格式化日期的方法
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 📌 ListView 填滿剩下空間
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(5),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          bool showTime = true;
                          bool showAvatar = true;

                          if (index < _messages.length - 1) {
                            final nextMessage = _messages[index + 1];
                            // 如果下一則是同一人，時間跟頭像都不顯示
                            if (nextMessage.isMe == message.isMe) {
                              showTime = false;
                              if (!message.isMe) showAvatar = false;
                            }
                          }

                          return MessageBubble(
                            message: message,
                            showTime: showTime,
                            showAvatar: showAvatar,
                            avatar: widget.avatar,
                            myLanguage: widget.myLanguage,
                          );
                        },
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 下方輸入框
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MessageInput(
                controller: _inputController,
                onSend: _sendMessage,
                // onListen: _listen,
                isListening: _isListening,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
