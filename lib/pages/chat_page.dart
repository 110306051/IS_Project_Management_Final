import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'chat_list_page.dart';

// import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatPage extends StatefulWidget {
  final String name;
  final String avatar;
  const ChatPage({super.key, required this.name, required this.avatar});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.initialize(
      onStatus: (val) => print('🎙️ onStatus: $val'),
      onError: (val) => print('❌ onError: $val'),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult:
              (val) => setState(() {
                _inputController.text = val.recognizedWords;
                _inputController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _inputController.text.length),
                );
              }),
          localeId: 'zh-TW', // 可改 'en-US'
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;

    final message = Message(
      sender: '我',
      text: _inputController.text.trim(),
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(message);
    });

    _inputController.clear();

    _scrollToBottom(); // 直接呼叫

    // 模擬對方回覆
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          Message(
            sender: '對方',
            text: 'I am fine, thank you!',
            timestamp: DateTime.now(),
            isMe: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // String _formatToday() {
  //   final now = DateTime.now();
  //   return ' ${now.year}年 ${now.month}月${now.day}日';
  // }

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
                onListen: _listen,
                isListening: _isListening,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
