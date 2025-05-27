import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String userId) {
    socket = IO.io('http://192.168.66.21:8000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'user_id': userId},
    });

    socket.on('connect', (_) {
      print('connect');
    });

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
  }

  void sendMessage(Map<String, dynamic> message) {
    socket.emit('send_message', message);
  }

  void onReceiveMessage(Function(dynamic) callback) {
    socket.on('receive_message', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}

final socketService = SocketService();
