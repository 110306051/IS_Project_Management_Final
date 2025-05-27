import 'package:flutter/material.dart';
import 'package:maria_frontend/pages/chat_page.dart';
import '../widgets/chat_list_item.dart';

class ChatListPage extends StatelessWidget {
  // const ChatListPage({super.key});

  final List<Map<String, dynamic>> chatList = [
    {
      'name': 'Jeremy',
      'avatar': 'assets/images/me.jpg',
      'lastMessage': 'Eat my ass？',
      'time': '3:10',
      'chatroomId': 'chatroom_01',
    },
    {
      'name': 'Sheng Hong',
      'avatar': 'https://via.placeholder.com/150',
      'lastMessage': 'Im stupid OKC fan.',
      'time': '12:30',
    },
    {
      'name': 'Ming ming',
      'avatar': 'https://via.placeholder.com/150',
      'lastMessage': 'I love to be a military',
      'time': '5:30',
    },
    {
      'name': 'Nana',
      'avatar': 'https://via.placeholder.com/150',
      'lastMessage': 'Nice to meet you',
      'time': '1:15',
    },
    {
      'name': 'KJ Hong',
      'avatar': 'https://via.placeholder.com/150',
      'lastMessage': 'Lets go work out?',
      'time': '10:30',
    },
    {
      'name': '小睿睿',
      'avatar': 'https://via.placeholder.com/150',
      'lastMessage': '湖人總冠軍～',
      'time': '7:00',
    },
  ];

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
                Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xfff4f7f7),
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
    );
  }
}
