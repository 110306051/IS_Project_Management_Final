import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  // final VoidCallback onListen;
  final bool isListening;

  const MessageInput({
    required this.controller,
    required this.onSend,
    // required this.onListen,
    required this.isListening,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: '輸入訊息...',
              hintStyle: TextStyle(color: Colors.white),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 255, 255, 255), // 輸入框邊框顏色（未聚焦）
                  width: 1.5,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xfffd999a), // 輸入框邊框顏色（聚焦時）
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
        // IconButton(
        //   icon: Icon(
        //     isListening ? Icons.mic : Icons.mic_none,
        //     color: isListening ? Colors.red : Colors.white,
        //   ),
        //   // onPressed: onListen,
        // ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: onSend,
          color: Colors.white,
        ),
      ],
    );
  }
}
