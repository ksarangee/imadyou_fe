import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청 패키지
import 'dart:html' as html;

import '../main.dart';

class IMissYouDetailPage extends StatefulWidget {
  const IMissYouDetailPage({super.key});

  @override
  _IMissYouDetailPageState createState() => _IMissYouDetailPageState();
}

class _IMissYouDetailPageState extends State<IMissYouDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  late html.WebSocket _socket;

  @override
  void initState()
  {
    super.initState();
    _connectWebSocket();
  }



  void _connectWebSocket() {
    final userName = Uri.encodeComponent(MyApp.currentUserName);  // URL 인코딩
    final url = "ws://3.38.95.45:80/chat/$userName";

    // final url = "ws://localhost:8000/chat/$userName";
    _socket = html.WebSocket(url);

    // 헤더에 토큰을 포함하여 WebSocket 연결 설정
    _socket.onOpen.listen((event) {
      print('WebSocket connected');
    });

    _socket.onClose.listen((event) {
      print('WebSocket closed');
    });

    _socket.onMessage.listen((event) {
      setState(() {
        _messages.insert(0, event.data);
      });
    });

    _socket.onError.listen((event) {
      print('WebSocket error: ${event.type}');
    });
  }


  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _socket.sendString(_controller.text);
      setState(() {
        // _messages.insert(0, _controller.text);
        _controller.clear();
      });
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
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 300),
                    child: CustomPaint(
                      painter: BubblePainter(),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                        child: Text(_messages[index]),
                      ),
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
                    width: MediaQuery.of(context).size.width * 0.6, // 넓이 조정
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48, // 높이 조정
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF6E6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double radius = 20;
    const double tailWidth = 10;
    const double tailHeight = 10;

    final path = Path()
      ..moveTo(size.width - radius, 0)
      ..lineTo(radius, 0)
      ..quadraticBezierTo(0, 0, 0, radius)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(size.width - radius - tailWidth, size.height)
      ..quadraticBezierTo(size.width - tailWidth, size.height,
          size.width - tailWidth, size.height - tailHeight)
      ..lineTo(size.width, size.height - tailHeight - 2)
      ..lineTo(size.width - tailWidth, size.height - tailHeight - 13)
      ..lineTo(size.width - tailWidth, radius / 1.5)
      ..quadraticBezierTo(
          size.width - tailWidth, 0, size.width - radius * 1.3, 0);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


