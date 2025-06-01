import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool showTime;
  final bool showAvatar;
  final String avatar;
  final String myLanguage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showTime,
    required this.showAvatar,
    required this.avatar,
    required this.myLanguage,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  // 當訊息被點擊時，讀出訊息內容
  Future<void> _speak(String text) async {
    if (widget.myLanguage == 'Traditional Chinese') {
      await flutterTts.setLanguage('zh-TW');
    } else if (widget.myLanguage == 'Indonesian') {
      await flutterTts.setLanguage('id-ID');
    } else {
      await flutterTts.setLanguage('en-US');
    }

    // await flutterTts.setVoice({'name': 'zh-tw-x-lia#male_2-local'});
    await flutterTts.setSpeechRate(0.7);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
    // List<dynamic> languages = await flutterTts.getVoices;

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('${languages}')));
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour;
    return '$formattedHour:$minute $period';
  }

  void _showTermsDialog(BuildContext context, List<Map<String, String>> terms) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                'Specialized Terms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  color: Color.fromARGB(255, 29, 39, 48),
                ),
              ),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: terms.length,
              itemBuilder: (context, index) {
                final entry = terms[index].entries.first;
                return ListTile(
                  leading: Icon(
                    Icons.label_important,
                    color: Color(0xfffd999a),
                  ),
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 29, 39, 48),
                    ),
                  ),
                  subtitle: Text(
                    entry.value,
                    style: TextStyle(color: Color.fromARGB(255, 29, 39, 48)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'close',
                style: TextStyle(color: Color.fromARGB(255, 29, 39, 48)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            widget.message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                widget.message.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              // 對方的頭像或空間占位
              if (!widget.message.isMe)
                SizedBox(
                  width: 40,
                  child:
                      widget.showAvatar
                          ? Align(
                            alignment: Alignment.bottomCenter,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(widget.avatar),
                            ),
                          )
                          : null,
                ),
              SizedBox(width: 10),
              // 氣泡訊息
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color:
                      widget.message.isMe
                          ? Color(0xfffd999a)
                          : Color(0xffe3dede),
                  borderRadius: BorderRadius.only(
                    bottomRight:
                        widget.message.isMe
                            ? Radius.circular(0)
                            : Radius.circular(10),
                    bottomLeft:
                        widget.message.isMe
                            ? Radius.circular(10)
                            : Radius.circular(0),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 訊息文字
                    Text(
                      widget.message.text,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color:
                            widget.message.isMe
                                ? Color(0xfff4f7f7)
                                : Color.fromARGB(255, 29, 39, 48),
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    // 如果有專業術語就顯示燈泡 icon
                    if (widget.message.specializedTerms.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                212,
                                209,
                                209,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              minimumSize: Size(0, 0), // 移除預設大小限制
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap, // 點擊範圍貼齊內容
                            ),
                            onPressed: () {
                              _showTermsDialog(
                                context,
                                widget.message.specializedTerms,
                              );
                            },
                            icon: Icon(
                              Icons.lightbulb,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            label: Text(
                              'Specialized Terms',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 2),
          // 發送時間
          if (widget.showTime)
            Padding(
              padding: EdgeInsets.only(
                left: !widget.message.isMe && widget.showAvatar ? 50.0 : 0.0,
                right: widget.message.isMe ? 0.0 : 0.0,
              ),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    widget.message.isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start, // ✅ 加這行控制左右對齊
                children: [
                  Text(
                    _formatTime(widget.message.timestamp),
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),

                  // IconButton(
                  //   padding: EdgeInsets.zero,
                  //   constraints: BoxConstraints(),
                  //   icon: Icon(
                  //     Icons.volume_up,
                  //     size: 20,
                  //     color: Colors.blueGrey,
                  //   ),
                  //   onPressed: () {
                  //     _speak(widget.message.text);
                  //   },
                  // ),
                  GestureDetector(
                    onTap: () {
                      _speak(widget.message.text);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 1), // 左邊距
                      width: 30, // 點擊區域寬度
                      height: 30, // 點擊區域高度
                      alignment: Alignment.center, // Icon 置中
                      child: Icon(
                        Icons.volume_up,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
