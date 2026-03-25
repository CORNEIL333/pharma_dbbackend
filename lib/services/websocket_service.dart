import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isAuthenticating = false;
  
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;
  
  bool get isConnected => _isConnected;

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  SessionInfo? _currentSession;

  void connect(SessionInfo session) {
    _currentSession = session;
    _reconnectTimer?.cancel();
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(session.wsUrl));
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['status'] == 'ok' && _isAuthenticating) {
            _isConnected = true;
            _isAuthenticating = false;
            _startPing();
          }
          _controller.add(data);
        },
        onDone: () {
          _handleDisconnect();
        },
        onError: (error) {
          _handleDisconnect();
        },
      );

      // Authentification
      _isAuthenticating = true;
      send({"token": session.token, "type": "auth"});
      
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _isAuthenticating = false;
    _pingTimer?.cancel();
    _channel = null;
    
    // Reconnexion auto toutes les 5 secondes
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_currentSession != null) {
        connect(_currentSession!);
      }
    });
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (_isConnected) {
        send({"type": "ping"});
      }
    });
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _currentSession = null;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
