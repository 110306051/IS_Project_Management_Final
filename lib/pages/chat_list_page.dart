import 'package:flutter/material.dart';
import 'package:maria_frontend/pages/chat_page.dart';
import '../widgets/chat_list_item.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../services/socket_service.dart';
import '../pages/login_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // const ChatListPage({super.key});
  // Button 位置狀態
  Offset buttonPosition = Offset(0, 0);
  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    final socketService = SocketService(); //* SocketService 用來處理 WebSocket 連線
    TokenService.getUsername().then((value) {
      if (value != null) {
        ApiService.globalUsername = value;
      }
    });
    _fetchChatrooms();
    TokenService.getUsername().then((value) {
      if (value != null) {
        socketService.connect(value);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        buttonPosition = Offset(size.width - 95, size.height - 130);
      });
    });
  }

  Future<void> _fetchChatrooms() async {
    final chatrooms = await ApiService.getChatrooms();

    setState(() {
      chatList =
          chatrooms.map((room) {
            return {
              'name': room['with_user'],
              'avatar': 'https://via.placeholder.com/150', // 如果還沒上傳大頭貼，先放預設
              'lastMessage': 'Hi 👋', // 如果沒有 lastMessage，這裡可以先寫死或放空字串
              'time': 'Now', // 同上，或是後端可以回傳最後訊息時間
              'chatroomId': room['chatroom_id'].toString(),
            };
          }).toList();
    });
  }

  void _showCreateChatroomDialog(BuildContext context) {
    final TextEditingController _user2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(15),
          // ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: const Text('Add Friend'),
          content: TextField(
            controller: _user2Controller,
            decoration: const InputDecoration(labelText: 'UserID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user2 = _user2Controller.text.trim();
                if (user2.isEmpty) return;

                // 假設這裡登入中的使用者名稱是 user1
                final user1 = ApiService.globalUsername;

                if (user1 == null) {
                  // 可以提示用戶重新登入或拋例外
                  print('Username is null');
                  return;
                }

                final result = await ApiService.createChatroom(user1, user2);

                if (result['status'] == 'success') {
                  // 關閉 Dialog
                  Navigator.pop(context);
                  // 成功通知
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Success!')));
                  // 重新抓聊天室列表
                  _fetchChatrooms();
                } else {
                  // 失敗通知
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ ${result['message']}')),
                  );
                }
              },
              child: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfffd999a), // 背景顏色
                foregroundColor: Colors.white, // 文字顏色
                shape: RoundedRectangleBorder(
                  // 圓角
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // final List<Map<String, dynamic>> chatList = [
  //   {
  //     'name': 'Jeremy',
  //     'avatar': 'assets/images/me.jpg',
  //     'lastMessage': 'Eat my ass？',
  //     'time': '3:10',
  //     'chatroomId': 'chatroom_01',
  //   },
  //   {
  //     'name': 'Sheng Hong',
  //     'avatar': 'https://via.placeholder.com/150',
  //     'lastMessage': 'Im stupid OKC fan.',
  //     'time': '12:30',
  //   },
  //   {
  //     'name': 'Ming ming',
  //     'avatar': 'https://via.placeholder.com/150',
  //     'lastMessage': 'I love to be a military',
  //     'time': '5:30',
  //   },
  //   {
  //     'name': 'Nana',
  //     'avatar': 'https://via.placeholder.com/150',
  //     'lastMessage': 'Nice to meet you',
  //     'time': '1:15',
  //   },
  //   {
  //     'name': 'KJ Hong',
  //     'avatar': 'https://via.placeholder.com/150',
  //     'lastMessage': 'Lets go work out?',
  //     'time': '10:30',
  //   },
  //   {
  //     'name': '小睿睿',
  //     'avatar': 'https://via.placeholder.com/150',
  //     'lastMessage': '湖人總冠軍～',
  //     'time': '7:00',
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 39, 48),

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 頂部 Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10,
                  ),
                  child: Stack(
                    children: [
                      Align(alignment: Alignment.centerLeft),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'MigrateAI',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,

                            color: Color(0xfff4f7f7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xfff4f7f7),
                      ),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        final socketService =
                            SocketService(); //* SocketService 用來處理 WebSocket 連線
                        TokenService.removeUsername();
                        TokenService.removeToken();
                        socketService.disconnect();
                        // 清除 SocketService 的連線
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xfff4f7f7),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Calls',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xfff4f7f7),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // 中間訊息區 填滿剩下空間
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xfff4f7f7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent Chats 標題
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 20),
                          child: Text(
                            'Recent Chats',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 39, 48),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Recent Chats 列表（取前 4 筆）
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatList.length >= 4 ? 4 : chatList.length,
                          itemBuilder: (context, index) {
                            final chat = chatList[index];
                            return ChatListItem(
                              name: chat['name'],
                              avatar: chat['avatar'],
                              lastMessage: chat['lastMessage'],
                              time: chat['time'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatPage(
                                          name: chat['name'],
                                          avatar: chat['avatar'],
                                          chatroomId:
                                              chat['chatroomId'] ??
                                              'default_chatroom',
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 10),
                        ),

                        const SizedBox(height: 20),

                        // All Chats 標題
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'All Chats',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 39, 48),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // All Chats 列表（顯示全部）
                        Expanded(
                          child: ListView.separated(
                            itemCount: chatList.length,
                            itemBuilder: (context, index) {
                              final chat = chatList[index];
                              return ChatListItem(
                                name: chat['name'],
                                avatar: chat['avatar'],
                                lastMessage: chat['lastMessage'],
                                time: chat['time'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ChatPage(
                                            name: chat['name'],
                                            avatar: chat['avatar'],
                                            chatroomId:
                                                chat['chatroomId'] ??
                                                'default_chatroom',
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 懸浮按鈕
          Positioned(
            left: buttonPosition.dx,
            top: buttonPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newX = buttonPosition.dx + details.delta.dx;
                  double newY = buttonPosition.dy + details.delta.dy;

                  newX = newX.clamp(0.0, size.width - 56);
                  newY = newY.clamp(0.0, size.height - 56);

                  buttonPosition = Offset(newX, newY);
                });
              },
              child: SizedBox(
                width: 65,
                height: 65,
                child: FloatingActionButton(
                  backgroundColor: Color(0xfffd999a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圓角矩形
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                  onPressed: () => _showCreateChatroomDialog(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
