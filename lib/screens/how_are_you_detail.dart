import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:http/http.dart' as http; // HTTP 요청 패키지
import 'dart:convert'; // JSON 처리 패키지
import 'package:imadyou/utils/number_name.dart';
import '../main.dart';

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
    //이름 목록
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
    //애니메이션 컨트롤러 초기화랑 반복 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    for (int i = 0; i < _circleNames.length; i++) {
      _circles.add(Circle(
        position:
            Offset(_random.nextDouble() * 300, _random.nextDouble() * 600),
        velocity: Offset((_random.nextDouble() * 4 - 2) * 1.6,
            (_random.nextDouble() * 4 - 2) * 1.6),
        name: _circleNames[i],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose(); //애니메이션 컨트롤러 해제
    super.dispose();
  }

  // 서버에서 받아온 근황 데이터를 저장할 리스트
  List<Entry> _serverEntries = [];

  // 서버에서 근황 데이터 가져오는 함수
  Future<void> _fetchEntries(String circleName) async {
    int number = nameToNumber[circleName] ?? 0;
    print('Fetching entries for $circleName (number: $number)');

    final response =
        await http.get(Uri.parse('http://3.38.96.220/how/$number'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _serverEntries = data
            .map((item) => Entry(
                  startDate: item['startDate'],
                  endDate: item['endDate'],
                  content: item['status_content'],
                  statusPK: item['status_PK'],
                ))
            .toList();
      });
    } else {
      // 오류 처리
      print('Failed to load entries');
    }
  }

  // 근황 수정 함수
  Future<void> _updateEntry(int number, Entry entry) async {
    print('Updating entry for number $number: ${entry.statusPK}');

    final response = await http.post(
      Uri.parse('http://3.38.96.220/how/$number/update/${entry.statusPK}'),
      body: json.encode({
        'startDate': entry.startDate,
        'endDate': entry.endDate,
        'status_content': entry.content,
        'status_PK': entry.statusPK,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyApp.accessToken}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // 수정 성공
      print('Entry updated successfully');
    } else {
      // 오류 처리
      print('Failed to update entry');
    }
  }

// 새 근황 추가 함수
  Future<void> _addEntry(int number, Entry entry) async {
    print('Adding new entry for number $number');

    final response = await http.post(
      Uri.parse('http://3.38.96.220/how/$number/add'),
      body: json.encode({
        'startDate': entry.startDate,
        'endDate': entry.endDate,
        'status_content': entry.content,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyApp.accessToken}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // 추가 성공
      print('Entry added successfully');
      // 새로운 데이터 가져오기
      await _fetchEntries(numberToName[number] ?? '');
    } else {
      // 오류 처리
      print('Failed to add entry');
    }
  }

  void _showPopup(BuildContext context, String circleName) {
    // 팝업을 표시하기 전에 서버에서 데이터를 가져옴
    _fetchEntries(circleName).then((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
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
                          itemCount: _serverEntries.length,
                          itemBuilder: (context, index) {
                            return _buildEntry(_serverEntries[index],
                                (updatedEntry) {
                              setState(() {
                                _serverEntries[index] = updatedEntry;
                              });
                              // 수정된 근황 서버에 업데이트
                              _updateEntry(
                                  nameToNumber[circleName] ?? 0, updatedEntry);
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
                                _serverEntries.add(Entry(
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
    });
  }

  Widget _buildEntry(Entry entry, Function(Entry) onUpdate) {
    // KAIST 몰입캠프 참여 정보는 수정 불가능하도록 처리
    bool isKAISTEntry = entry.startDate == "24.06.27" &&
        entry.endDate == "24.07.28" &&
        entry.content == "KAIST 몰입캠프 참여 [3분반]";

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
                        //시작일 선택
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
                        //종료일 선택
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
              // 근황 내용 표시 또는 수정
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
              if (!isKAISTEntry) // KAIST 몰입캠프 참여 정보가 아닌 경우에만 수정 버튼 표시
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
          _updateCirclePositions(); //원(이미지) 위치 업데이트
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
                          width: 90,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: circle.isHovered
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Image.asset(
                            'assets/images/${circle.name}.png',
                            fit: BoxFit.contain,
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

  //원(이미지)의 위치를 업데이트하는 함수
  void _updateCirclePositions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final circleDiameter = 90.0;

    for (var circle in _circles) {
      Offset newPosition = circle.position + circle.velocity;

      //화면 경계를 넘어가지 않도록 처리
      if (newPosition.dx <= 0) {
        circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        newPosition = Offset(0, newPosition.dy);
      } else if (newPosition.dx >= screenWidth - circleDiameter) {
        circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        newPosition = Offset(screenWidth - circleDiameter, newPosition.dy);
      }

      if (newPosition.dy <= 0) {
        circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        newPosition = Offset(newPosition.dx, 0);
      } else if (newPosition.dy >= screenHeight - circleDiameter) {
        circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        newPosition = Offset(newPosition.dx, screenHeight - circleDiameter);
      }

      //원들이 충돌했을 때
      for (var other in _circles) {
        if (circle != other) {
          if ((newPosition - other.position).distance < circleDiameter) {
            circle.velocity = Offset(-circle.velocity.dx, -circle.velocity.dy);
            other.velocity = Offset(-other.velocity.dx, -other.velocity.dy);
          }
        }
      }

      circle.position = newPosition;
    }
  }
}

class Circle {
  Offset position;
  Offset velocity;
  final String name;
  bool isHovered = false;

  Circle({
    required this.position,
    required this.velocity,
    required this.name,
  });
}

class Entry {
  String startDate;
  String endDate;
  String content;
  bool isEditing;
  int? statusPK; // 서버에서 받아온 근황 PK 필드

  Entry({
    required this.startDate,
    required this.endDate,
    required this.content,
    this.isEditing = false,
    this.statusPK,
  });
}