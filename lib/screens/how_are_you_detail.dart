import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HowAreYouDetailPage extends StatefulWidget {
  const HowAreYouDetailPage({super.key});

  @override
  _HowAreYouDetailPageState createState() => _HowAreYouDetailPageState();
}

class _HowAreYouDetailPageState extends State<HowAreYouDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Circle> _circles = [];
  final Random _random = Random();
  final List<String> _circleNames = [
    '재용',
    '사랑',
    '지원',
    '동연',
    '수환',
    '원중',
    '은서',
    '진환',
    '준형',
    '수민',
    '서원',
    '지형',
    '수연',
    '시웅',
    '시준',
    '예린',
    '지혁',
    '효정',
    '우성',
    '재현',
    '종민',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    for (int i = 0; i < _circleNames.length; i++) {
      _circles.add(Circle(
        position:
            Offset(_random.nextDouble() * 300, _random.nextDouble() * 600),
        velocity: Offset((_random.nextDouble() * 4 - 2) * 1.2,
            (_random.nextDouble() * 4 - 2) * 1.2),
        color: Color.fromARGB(255, _random.nextInt(256), _random.nextInt(256),
            _random.nextInt(256)),
        name: _circleNames[i],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPopup(BuildContext context, String circleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        List<Entry> entries = [
          Entry(
            startDate: "24.06.27",
            endDate: "24.07.28",
            content: "KAIST 몰입캠프 참여 [3분반]",
          )
        ];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF8F1),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("How is $circleName?"),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return _buildEntry(entries[index], (updatedEntry) {
                            setState(() {
                              entries[index] = updatedEntry;
                            });
                          });
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              entries.add(Entry(
                                  startDate: "",
                                  endDate: "",
                                  content: "",
                                  isEditing: true));
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEntry(Entry entry, Function(Entry) onUpdate) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/how_tag.png',
                    width: 170,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 20,
                    left: 10,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: entry.isEditing
                              ? () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2044),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Color(0xFFFFE7C2),
                                            onPrimary: Color(0xFF484848),
                                            surface: Color(0xFFFFE7C2),
                                            onSurface: Color(0xFF484848),
                                          ),
                                          dialogBackgroundColor:
                                              Color(0xFFFFE7C2),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Color(0xFF484848),
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      entry.startDate = DateFormat('yy.MM.dd')
                                          .format(pickedDate);
                                    });
                                  }
                                }
                              : null,
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              entry.startDate.isEmpty ? "시작일" : entry.startDate,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: entry.startDate.isEmpty
                                      ? Color(0xFFA3A09D)
                                      : Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Text(" ~ ", style: TextStyle(fontSize: 14)),
                        GestureDetector(
                          onTap: entry.isEditing
                              ? () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2044),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Color(0xFFFFE7C2),
                                            onPrimary: Color(0xFF484848),
                                            surface: Color(0xFFFFE7C2),
                                            onSurface: Color(0xFF484848),
                                          ),
                                          dialogBackgroundColor:
                                              Color(0xFFFFE7C2),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Color(0xFF484848),
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      entry.endDate = DateFormat('yy.MM.dd')
                                          .format(pickedDate);
                                    });
                                  }
                                }
                              : null,
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              entry.endDate.isEmpty ? "종료일" : entry.endDate,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: entry.endDate.isEmpty
                                      ? Color(0xFFA3A09D)
                                      : Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: entry.isEditing
                    ? TextField(
                        controller: TextEditingController(text: entry.content),
                        onChanged: (value) {
                          entry.content = value;
                        },
                        decoration:
                            const InputDecoration(hintText: '근황을 적어주세요!'),
                      )
                    : Text(entry.content, style: TextStyle(fontSize: 17)),
              ),
              IconButton(
                icon: Icon(entry.isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    if (entry.isEditing) {
                      if (entry.startDate.isEmpty) {
                        entry.startDate =
                            DateFormat('yy.MM.dd').format(DateTime.now());
                      }
                      if (entry.endDate.isEmpty) {
                        entry.endDate = "현재";
                      }
                    }
                    entry.isEditing = !entry.isEditing;
                    onUpdate(entry);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateCirclePositions();
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/how_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: MediaQuery.of(context).size.width / 2 - 100,
                  child: const Text(
                    "How is Everyone?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._circles.map((circle) {
                  return Positioned(
                    left: circle.position.dx,
                    top: circle.position.dy,
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          circle.isHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          circle.isHovered = false;
                        });
                      },
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            circle.position += details.delta;
                          });
                        },
                        onTap: () => _showPopup(context, circle.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 30,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circle.color,
                            boxShadow: circle.isHovered
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateCirclePositions() {
    for (var circle in _circles) {
      Offset newPosition = circle.position + circle.velocity;

      if (newPosition.dx <= 0 ||
          newPosition.dx >= MediaQuery.of(context).size.width - 30) {
        circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
      }

      if (newPosition.dy <= 0 ||
          newPosition.dy >= MediaQuery.of(context).size.height - 30) {
        circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
      }

      for (var other in _circles) {
        if (circle != other) {
          if ((newPosition - other.position).distance < 30) {
            circle.velocity = Offset(-circle.velocity.dx, -circle.velocity.dy);
            other.velocity = Offset(-other.velocity.dx, -other.velocity.dy);
          }
        }
      }

      circle.position = circle.position + circle.velocity;
    }
  }
}

class Circle {
  Offset position;
  Offset velocity;
  final Color color;
  final String name;
  bool isHovered = false;

  Circle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.name,
  });
}

class Entry {
  String startDate;
  String endDate;
  String content;
  bool isEditing;

  Entry({
    required this.startDate,
    required this.endDate,
    required this.content,
    this.isEditing = false,
  });
}
