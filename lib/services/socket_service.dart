import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool isConnected = false;

  void connect(String userId) {
    if (isConnected) return;
    socket = IO.io('http://10.0.2.2:8000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'user_id': userId},
    });

    socket.on('connect', (_) {
      print('connect');
      isConnected = true;
    });

    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
  }

  void sendMessage(Map<String, dynamic> message) {
    socket.emit('send_message', message);
  }

  void onReceiveMessage(Function(dynamic) callback) {
    socket.off('receive_message'); // 先移除舊的
    socket.on('receive_message', callback);
  }

  void disconnect() {
    socket.disconnect();
    isConnected = false;
  }
}

// final socketService = SocketService();
