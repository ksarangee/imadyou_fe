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
  String currentUserName = '';

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화 및 반복 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // 화면 크기 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      for (int i = 0; i < _circleNames.length; i++) {
        _circles.add(Circle(
          position: Offset(_random.nextDouble() * (screenWidth - 90),
              _random.nextDouble() * (screenHeight - 110)),
          velocity: Offset((_random.nextDouble() * 4 - 2) * 1.6,
              (_random.nextDouble() * 4 - 2) * 1.6),
          name: _circleNames[i],
        ));
      }
      _getCurrentUserName();
    });
  }

  // 현재 로그인한 사용자의 이름을 가져오는 함수
  void _getCurrentUserName() {
    setState(() {
      currentUserName = MyApp.currentUserName;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); //애니메이션 컨트롤러 해제
    super.dispose();
  }

  void _removeEntry(String statusPK) {
    setState(() {
      _serverEntries.removeWhere((e) => e.statusPK == statusPK);
    });
  }

  // 서버에서 받아온 근황 데이터를 저장할 리스트
  List<Entry> _serverEntries = [];

  // 서버에서 근황 데이터 가져오는 함수
  Future<void> _fetchEntries(String circleName) async {
    int number = nameToNumber[circleName] ?? 0;
    print('Fetching entries for $circleName (number: $number)');

    final response = await http.get(Uri.parse('http://3.38.95.45/how/$number'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _serverEntries = data
            .map((item) => Entry(
                  startDate: item['start_date'],
                  endDate: item['end_date'],
                  content: item['content'],
                  statusPK: item['_id'],
                  userNum: number,
                ))
            .toList();

        // KAIST 몰입캠프 참여 정보 추가
        _serverEntries.insert(
            0,
            Entry(
              startDate: "24.06.27",
              endDate: "24.07.28",
              content: "KAIST 몰입캠프 참여 [3분반]",
              isEditing: false,
              statusPK: '-1', // 특별한 값을 사용하여 고정 항목임을 표시
            ));
      });
    } else {
      // 오류 처리
      print('Failed to load entries');
    }
  }

  // 근황 수정 함수
  Future<void> _updateEntry(int number, Entry entry) async {
    print('Updating entry for number $number: ${entry.statusPK}');

    final response = await http.put(
      Uri.parse('http://3.38.95.45/how/$number/update/${entry.statusPK}'),
      body: json.encode({
        'start_date': entry.startDate,
        'end_date': entry.endDate,
        'content': entry.content,
        '_id': entry.statusPK,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyApp.accessToken}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${utf8.decode(response.bodyBytes)}');

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
      Uri.parse('http://3.38.95.45/how/$number/add'),
      body: json.encode({
        'start_date': entry.startDate,
        'end_date': entry.endDate,
        'content': entry.content,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyApp.accessToken}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      // 추가 성공
      print('Entry added successfully');
      // 서버 응답에서 새로 생성된 항목의 statusPK를 가져옵니다
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      final newStatusPK = responseBody['_id'];

      setState(() {
        // 새로 추가된 항목의 statusPK를 설정합니다
        entry.statusPK = newStatusPK;
      });
    } else {
      // 오류 처리
      print('Failed to add entry');
    }
  }

  //근황 삭제 함수
  Future<void> _deleteEntry(int number, String statusPK) async {
    print('Deleting entry for number $number: $statusPK');

    final response = await http.delete(
      Uri.parse('http://3.38.95.45/how/$number/delete/$statusPK'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyApp.accessToken}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      // 삭제 성공
      print('Entry deleted successfully');
    } else {
      // 오류 처리
      print('Failed to delete entry');
      // 오류 발생 시 사용자에게 알림을 표시할 수 있습니다.
    }
  }

  void _showPopup(BuildContext context, String circleName) {
    int number = nameToNumber[circleName] ?? 0;

    //현재 사용자와 선택된 이미지의 이름이 일치하는지 확인
    bool isCurrentUser = currentUserName == circleName;

    // 팝업을 표시하기 전에 서버에서 데이터를 가져옴
    _fetchEntries(circleName).then((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/images/cv_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 20.0, 24.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                      text: circleName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26.0,
                                          color: Color(0xFF3F3838))),
                                  TextSpan(
                                      text: "님은 어떻게 지내나요?",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          color: Color(0xFF3F3838))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _serverEntries.length,
                          itemBuilder: (context, index) {
                            return _buildEntry(
                              _serverEntries[index],
                              (updatedEntry) {
                                setState(() {
                                  _serverEntries[index] = updatedEntry;
                                });
                                _updateEntry(number, updatedEntry);
                              },
                              number,
                              isCurrentUser,
                              (statusPK) {
                                setState(() {
                                  _serverEntries.removeWhere(
                                      (e) => e.statusPK == statusPK);
                                });
                                _removeEntry(statusPK);
                              },
                            );
                          },
                        ),
                      ),
                      if (isCurrentUser)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                final newEntry = Entry(
                                  startDate: "",
                                  endDate: "",
                                  content: "",
                                  isEditing: true,
                                  statusPK:
                                      'temp_${DateTime.now().millisecondsSinceEpoch}',
                                );
                                setState(() {
                                  _serverEntries.add(newEntry);
                                });
                                await _addEntry(number, newEntry);
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

  Widget _buildEntry(Entry entry, Function(Entry) onUpdate, int number,
      bool isCurrentUser, Function(String) onDelete) {
    // KAIST 몰입캠프 참여 정보는 수정 불가능하도록 처리
    bool isKAISTEntry = entry.startDate == "24.06.27" &&
        entry.endDate == "24.07.28" &&
        entry.content == "KAIST 몰입캠프 참여 [3분반]";

    bool isNewEntry =
        entry.statusPK == null || entry.statusPK == '-1'; // 새 Entry인지 확인

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
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
                        // 시작일 선택
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
                        // 종료일 선택
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
                    : Text(entry.content,
                        style:
                            TextStyle(fontSize: 17, color: Color(0xFF3F3838))),
              ),
              if (!isKAISTEntry &&
                  isCurrentUser) // KAIST 몰입캠프 참여 정보가 아닌 경우에만 수정 및 삭제 버튼 표시
                Row(
                  children: [
                    IconButton(
                      icon: Icon(entry.isEditing ? Icons.check : Icons.edit),
                      onPressed: () async {
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
                        });

                        if (!entry.isEditing) {
                          if (isNewEntry) {
                            // 새 Entry를 추가
                            await _addEntry(number, entry);
                          } else {
                            // 기존 Entry를 업데이트
                            await _updateEntry(number, entry);
                          }
                          // 데이터 새로고침
                          String circleName = numberToName[number] ?? 'Unknown';
                          // 성빼고 name to number하기
                          if (circleName.length > 1) {
                            circleName = circleName.substring(1);
                          }
                          await _fetchEntries(circleName);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        if (entry.statusPK != null && entry.statusPK != '-1') {
                          await _deleteEntry(number, entry.statusPK!);
                          onDelete(entry.statusPK!);
                        } else {
                          // 새로 추가된 항목이지만 아직 서버에 저장되지 않은 경우
                          onDelete('temp_${entry.hashCode}');
                        }
                      },
                    ),
                  ],
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

      // 화면 경계를 넘어가지 않도록 처리
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

      // 원들이 충돌했을 때
      for (var other in _circles) {
        if (circle != other) {
          final distance = (newPosition - other.position).distance;
          if (distance < circleDiameter) {
            // 벡터의 각도와 크기를 통해 충돌 벡터 계산
            Offset collisionVector =
                (newPosition - other.position) / distance; // 단위 벡터로 변환

            // 벡터를 기준으로 속도를 반사시키기
            circle.velocity = _reflect(circle.velocity, collisionVector);
            other.velocity = _reflect(other.velocity, collisionVector);

            // 충돌 후 위치 조정
            double overlap = 0.5 * (circleDiameter - distance);
            Offset adjustment = Offset(
              overlap * collisionVector.dx,
              overlap * collisionVector.dy,
            );

            newPosition += adjustment;
          }
        }
      }

      circle.position = newPosition;
    }
  }

  Offset _reflect(Offset velocity, Offset normal) {
    // 반사 벡터 계산
    double dotProduct = velocity.dx * normal.dx + velocity.dy * normal.dy;
    return Offset(
      velocity.dx - 2 * dotProduct * normal.dx,
      velocity.dy - 2 * dotProduct * normal.dy,
    );
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
  String? statusPK; // 서버에서 받아온 근황 PK 필드
  int? userNum;

  Entry({
    required this.startDate,
    required this.endDate,
    required this.content,
    this.isEditing = false,
    this.statusPK,
    this.userNum,
  });
}
