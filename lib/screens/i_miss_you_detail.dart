import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../main.dart';

class Message {
  final String content;
  final bool isFromCurrentUser;
  final String sender;
  final String timestamp;

  Message(this.content, this.isFromCurrentUser, this.sender, this.timestamp);
}

class IMissYouDetailPage extends StatefulWidget {
  const IMissYouDetailPage({super.key});

  @override
  _IMissYouDetailPageState createState() => _IMissYouDetailPageState();
}

class _IMissYouDetailPageState extends State<IMissYouDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  late html.WebSocket _socket;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final userName = Uri.encodeComponent(MyApp.currentUserName);
    print('Current user name: ${MyApp.currentUserName}');
    final url = "ws://3.38.95.45:80/chat/$userName";

    _socket = html.WebSocket(url);

    _socket.onOpen.listen((event) {
      print('WebSocket connected');
    });

    _socket.onClose.listen((event) {
      print('WebSocket closed');
    });

    _socket.onMessage.listen((event) {
      try {
        // 수신한 데이터를 문자열로 저장
        final rawMessage = event.data;

        // 문자열 포맷에 맞게 파싱
        final regex =
            RegExp(r"#(.+): (.+) \((\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2})\)");
        final match = regex.firstMatch(rawMessage);

        if (match != null) {
          final sender = match.group(1);
          final message = match.group(2);
          final timestamp = match.group(3);

          if (sender != null && message != null && timestamp != null) {
            setState(() {
              _messages.insert(
                  0,
                  Message(message, sender == MyApp.currentUserName, sender,
                      timestamp));
            });
          } else {
            print(
                'Parsed values are null: sender=$sender, message=$message, timestamp=$timestamp');
          }
        } else {
          print('Invalid message format: $rawMessage');
        }
      } catch (e) {
        print('Error parsing message: $e');
        print('Received data: ${event.data}');
      }
    });

    _socket.onError.listen((event) {
      print('WebSocket error: ${event.type}');
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      _socket.sendString(message);
      _controller.clear(); // 메시지 전송 후 텍스트 필드 초기화
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F1),
        title: const Text(
          "3분반의 담벼락",
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isFromCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: message.isFromCurrentUser ? 300 : 250,
                    ),
                    child: Column(
                      crossAxisAlignment: message.isFromCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!message.isFromCurrentUser)
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5),
                            child: Text(
                              message.sender,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        CustomPaint(
                          painter: BubblePainter(message.isFromCurrentUser),
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7),
                            padding: EdgeInsets.fromLTRB(
                                message.isFromCurrentUser ? 10 : 20,
                                10,
                                message.isFromCurrentUser ? 20 : 10,
                                10),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 5,
                            right: message.isFromCurrentUser ? 10 : 0,
                            left: message.isFromCurrentUser ? 0 : 10,
                          ),
                          child: Text(
                            message.timestamp,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF6E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: _sendMessage,
                    child: const Text(
                      '전송',
                      style: TextStyle(color: Colors.black),
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

class BubblePainter extends CustomPainter {
  final bool isFromCurrentUser;

  BubblePainter(this.isFromCurrentUser);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFromCurrentUser ? const Color(0xFFFFF6E6) : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double radius = 20;
    const double tailWidth = 10;
    const double tailHeight = 10;

    final path = Path();

    if (isFromCurrentUser) {
      path.moveTo(size.width - radius, 0);
      path.lineTo(radius, 0);
      path.quadraticBezierTo(0, 0, 0, radius);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width - radius - tailWidth, size.height);
      path.quadraticBezierTo(size.width - tailWidth, size.height,
          size.width - tailWidth, size.height - tailHeight);
      path.lineTo(size.width, size.height - tailHeight - 2);
      path.lineTo(size.width - tailWidth, size.height - tailHeight - 13);
      path.lineTo(size.width - tailWidth, radius / 1.5);
      path.quadraticBezierTo(
          size.width - tailWidth, 0, size.width - radius * 1.3, 0);
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height);
      path.lineTo(radius + tailWidth, size.height);
      path.quadraticBezierTo(
          tailWidth, size.height, tailWidth, size.height - tailHeight);
      path.lineTo(0, size.height - tailHeight - 2);
      path.lineTo(tailWidth, size.height - tailHeight - 13);
      path.lineTo(tailWidth, radius / 1.5);
      path.quadraticBezierTo(tailWidth, 0, radius * 1.3, 0);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
