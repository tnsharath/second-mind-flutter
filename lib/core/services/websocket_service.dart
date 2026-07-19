import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/env.dart';

/// WebSocket channel for realtime streaming (voice, chat tokens).
///
/// TODO(backend): wire to the FastAPI websocket endpoint once available.
class WebSocketService {
  WebSocketChannel? _channel;

  bool get isConnected => _channel != null;

  Future<void> connect({String path = ''}) async {
    _channel = WebSocketChannel.connect(Uri.parse('${Env.wsBaseUrl}$path'));
    await _channel!.ready;
  }

  Stream<dynamic>? get stream => _channel?.stream;

  Future<void> send(Object data) async {
    _channel?.sink.add(data);
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
