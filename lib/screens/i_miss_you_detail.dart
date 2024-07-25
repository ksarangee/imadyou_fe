//my code
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../main.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

class Message {
  final String content;
  final bool isFromCurrentUser;
  final String sender;
  final String timestamp;

  Message(this.content, this.isFromCurrentUser, this.sender, this.timestamp);
}

class Petal {
  double x;
  double y;
  double size;
  double angle;
  double speed;

  Petal(this.x, this.y, this.size, this.angle, this.speed);
}

class IMissYouDetailPage extends StatefulWidget {
  const IMissYouDetailPage({super.key});

  @override
  _IMissYouDetailPageState createState() => _IMissYouDetailPageState();
}

class _IMissYouDetailPageState extends State<IMissYouDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  late html.WebSocket _socket;
  final List<Petal> _petals = [];
  late AnimationController _animationController;
  final int _petalCount = 50;
  final math.Random _random = math.Random();
  ui.Image? _petalImage;
  Offset? _mousePosition;

  Future<void> _loadPetalImage() async {
    final ByteData data = await rootBundle.load('assets/images/petal.png');
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      completer.complete(img);
    });
    _petalImage = await completer.future;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _initAnimation();
    _loadPetalImage().then((_) {
      _initPetals();
    });
  }

  void _initPetals() {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < _petalCount; i++) {
      _petals.add(Petal(
        _random.nextDouble() * size.width,
        _random.nextDouble() * size.height,
        10 + _random.nextDouble() * 15, // 크기를 10~25로
        _random.nextDouble() * 2 * math.pi,
        0.3 + _random.nextDouble() * 0.9, // 속도를 줄임
      ));
    }
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // 60 FPS로 설정
    )..addListener(() {
        _updatePetals();
      });
    _animationController.repeat();
  }

  void _updatePetals() {
    final size = MediaQuery.of(context).size;
    for (var petal in _petals) {
      petal.y += petal.speed;
      petal.x += math.sin(petal.angle) * 0.3; // x 축 움직임을 줄임
      petal.angle += 0.005; // 회전 속도를 줄임

      if (petal.y > size.height) {
        petal.y = -petal.size;
        petal.x = _random.nextDouble() * size.width;
      }

      if (_mousePosition != null) {
        _handleMouseInteraction(petal, _mousePosition!);
      }
    }
    setState(() {}); // 매 프레임마다 상태 업데이트
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

  void _handleMouseInteraction(Petal petal, Offset position) {
    double dx = position.dx - petal.x;
    double dy = position.dy - petal.y;
    double distance = math.sqrt(dx * dx + dy * dy);

    if (distance < 100) {
      // 상호작용 범위를 줄임
      double force = 1 - (distance / 100);
      petal.x -= (dx / distance) * force * 10; // 힘을 줄임
      petal.y -= (dy / distance) * force * 10;
      petal.angle += math.pi / 16 * force; // 회전 효과를 줄임
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _socket.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          color: const Color(0xFFFFF8F1),
          child: AppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F1),
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            _mousePosition = details.globalPosition;
          });
        },
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              _mousePosition = event.position;
            });
          },
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/chat_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              CustomPaint(
                painter: _petalImage != null
                    ? PetalPainter(_petals, _petalImage!)
                    : null,
                size: Size.infinite,
              ),
              Column(
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
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 5),
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
                                  painter:
                                      BubblePainter(message.isFromCurrentUser),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
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
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: '메시지를 입력하세요',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
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
                                  side: const BorderSide(
                                      color: Colors.black, width: 1),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
                ],
              ),
            ],
          ),
        ),
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

class PetalPainter extends CustomPainter {
  final List<Petal> petals;
  final ui.Image petalImage;

  PetalPainter(this.petals, this.petalImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var petal in petals) {
      canvas.save();
      canvas.translate(petal.x, petal.y);
      canvas.rotate(petal.angle);
      canvas.translate(-petal.size / 2, -petal.size / 2);
      canvas.drawImageRect(
        petalImage,
        Rect.fromLTWH(
            0, 0, petalImage.width.toDouble(), petalImage.height.toDouble()),
        Rect.fromLTWH(0, 0, petal.size, petal.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PetalPainter oldDelegate) => true;
}
