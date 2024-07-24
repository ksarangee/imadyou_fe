// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 임포트
import 'package:imadyou/utils/number_name.dart'; // 번호-이름 매핑 파일을 임포트
import 'package:imadyou/widgets/clock_widget.dart';
import 'dart:math';

class ISeeYouDetailPage extends StatefulWidget {
  const ISeeYouDetailPage({super.key});

  @override
  _ISeeYouDetailPageState createState() => _ISeeYouDetailPageState();
}

class _ISeeYouDetailPageState extends State<ISeeYouDetailPage> {
  String _selectedWeek = '1주차';
  double _overlayOpacity = 0.0;

  // 서버에서 받아올 데이터를 위한 변수들
  String _imageUrl = '';
  String _githubLink = '';
  List<String> _teamMembers = [];
  String _projectOverview = '';

  // 서버 응답 데이터를 저장할 리스트
  List<Map<String, dynamic>> _galleryData = [];

  final List<String> _week1TextsLeft = [
    'Mad-Connect',
    '스크럼블',
    '학연지연혈연',
    '젤리크러쉬사가',
    '생기'
  ];

  final List<String> _week1TextsRight = [
    'ArchiveCamp',
    'Spoon',
    'Spectrum',
    'MADIARY',
    'Dear.Prof'
  ];

  final List<String> _week2TextsLeft = [
    '바리바리',
    'Alquerithm',
    '농담',
    'tidbits',
    '얼분증'
  ];

  final List<String> _week2TextsRight = [
    '킥인',
    '새로',
    'MoneChat',
    'Potato',
    '더치 Dutch'
  ];

  final List<String> _week3TextsLeft = [
    'Momentum',
    '뻐끔뻐끔',
    'SyncManager',
    'COMT',
    'DarT'
  ];

  final List<String> _week3TextsRight = [
    '빠삐덥',
    '떠오르다',
    'Welcome to Xandar!',
    '넙죽아 죽이 짜다',
    '일상의 소설'
  ];

  String? _selectedProjectName; //클릭된 텍스트
  String? _hoveredProjectName;

  @override
  void initState() {
    super.initState();
    _fetchGalleryData(); // 데이터 가져오기
  }

  // 서버에서 주차별 데이터 가져오기
  Future<void> _fetchGalleryData() async {
    final url = 'http://3.38.95.45/gallery/${_selectedWeek[0]}';
    print('Sending request to: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> galleryData =
            json.decode(utf8.decode(response.bodyBytes));

        // 필요한 데이터만 저장
        setState(() {
          _galleryData = galleryData.cast<Map<String, dynamic>>();
        });

        print('Parsed gallery data: $_galleryData'); // 파싱된 데이터 로그
      } else {
        // 요청 실패 처리
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      print('Error fetching gallery data: $e');
    }
  }

  void _onTextTap(String text, bool isLeftColumn) {
    setState(() {
      _selectedProjectName = text; // 클릭된 텍스트 저장
      _hoveredProjectName = text; // 클릭된 텍스트가 현재 호버된 텍스트가 되도록 설정
    });

    final project = _fetchProjectDataByName(text);
    _updateSlidePanel(project);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      AssetImage('assets/images/see_pop_bg.png'), // 배경 이미지 설정
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 내부 패딩 추가
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedProjectName = null; // 팝업창 닫을 때 그림자 해제
                            _hoveredProjectName = null; // 호버 상태도 해제
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    if (_imageUrl.isNotEmpty)
                      Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Image.network(_imageUrl, fit: BoxFit.cover),
                      ),
                    SizedBox(height: 20),
                    Text(
                      'Github:',
                      style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    if (_githubLink.isNotEmpty)
                      GestureDetector(
                        onTap: () => _launchUrl(_githubLink),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _githubLink,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Text(
                      'Team:',
                      style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Text(
                        style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.bold,
                        ),
                        _teamMembers.join(', ')),
                    SizedBox(height: 20),
                    Text(
                      'Project Overview:',
                      style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Text(
                        style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.bold,
                        ),
                        _projectOverview),
                  ],
                ),
              ),
            ));
      },
    );
  }

  // 프로젝트 이름으로 데이터를 찾는 함수
  Map<String, dynamic> _fetchProjectDataByName(String projectName) {
    for (var project in _galleryData) {
      if (project['project_name'] == projectName) {
        return project;
      }
    }
    // 프로젝트 이름에 맞는 데이터를 찾지 못했을 경우 예외를 던짐
    throw Exception('Project not found: $projectName');
  }

  // 슬라이드 패널을 받아온 데이터로 업데이트
  void _updateSlidePanel(Map<String, dynamic> projectData) {
    setState(() {
      _imageUrl = projectData['thumbnail'];
      _githubLink = projectData['url'];
      _teamMembers = projectData['teammates']
          .map((number) => numberToName[number])
          .toList()
          .cast<String>(); // List<String> 타입으로 캐스팅
      _projectOverview = projectData['introduction'];
    });
  }

  // URL 열기 함수
  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF5F8),
      body: Stack(
        children: [
          // 배경 이미지 추가
          Positioned.fill(
            child: Image.asset(
              _getBackgroundImage(),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: DropdownButton<String>(
                    value: _selectedWeek,
                    dropdownColor: Color(0xFFEFF5F8),
                    items: <String>['1주차', '2주차', '3주차'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWeek = newValue!;
                        _fetchGalleryData(); // 주차 변경 시 데이터 다시 가져오기
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _buildDeskColumn(_getWeekTexts(true), true),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter, // 위쪽으로 정렬
                        child: ClockWidget(
                          onAngleChanged: (angle) {
                            setState(() {
                              _overlayOpacity = (angle + pi) / (2 * pi);
                            });
                          },
                        ),
                      ),
                    ),
                    _buildDeskColumn(_getWeekTexts(false), false),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _overlayOpacity * 0.3, //최대 불투명도
                duration: Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBackgroundImage() {
    switch (_selectedWeek) {
      case '1주차':
      case '2주차':
        return 'assets/images/window12.png';
      case '3주차':
        return 'assets/images/window3.png';
      default:
        return 'assets/images/window12.png';
    }
  }

  List<String>? _getWeekTexts(bool isLeft) {
    switch (_selectedWeek) {
      case '1주차':
        return isLeft ? _week1TextsLeft : _week1TextsRight;
      case '2주차':
        return isLeft ? _week2TextsLeft : _week2TextsRight;
      case '3주차':
        return isLeft ? _week3TextsLeft : _week3TextsRight;
      default:
        return null;
    }
  }

  Widget _buildDeskColumn(List<String>? texts, bool isLeftColumn) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final text = texts?[index];
          final isSelected = text == _selectedProjectName;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: [
                Image.asset('assets/images/desk.png'),
                if (text != null)
                  Positioned(
                      bottom: 8,
                      left: isLeftColumn ? 16 : null,
                      right: isLeftColumn ? null : 16,
                      child: MouseRegion(
                        onEnter: (_) => setState(() {
                          if (_selectedProjectName != text) {
                            // 선택된 텍스트가 아닌 경우에만 호버 처리
                            _hoveredProjectName = text;
                          }
                        }),
                        onExit: (_) => setState(() {
                          if (_selectedProjectName != text) {
                            // 선택된 텍스트가 아닌 경우에만 호버 해제
                            _hoveredProjectName = null;
                          }
                        }),
                        child: GestureDetector(
                          onTap: () => _onTextTap(text, isLeftColumn),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Color(0xFF595959),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              shadows: (text == _selectedProjectName ||
                                      text == _hoveredProjectName)
                                  ? [
                                      Shadow(
                                        blurRadius: 5.0,
                                        color: Colors.black.withOpacity(0.5),
                                        offset: Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          );
        }),
      ),
    );
  }
}
