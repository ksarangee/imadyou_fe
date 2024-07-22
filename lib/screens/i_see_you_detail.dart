// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 임포트
import 'package:imadyou/utils/number_name.dart'; // 번호-이름 매핑 파일을 임포트

class ISeeYouDetailPage extends StatefulWidget {
  const ISeeYouDetailPage({super.key});

  @override
  _ISeeYouDetailPageState createState() => _ISeeYouDetailPageState();
}

class _ISeeYouDetailPageState extends State<ISeeYouDetailPage>
    with SingleTickerProviderStateMixin {
  String _selectedWeek = '1주차';
  bool _showSlidePanel = false;
  String _slidePanelText = '';
  bool _slideFromLeft = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fetchGalleryData(); // 데이터 가져오기
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 서버에서 주차별 데이터 가져오기
  Future<void> _fetchGalleryData() async {
    final url = 'http://3.38.96.220/gallery/${_selectedWeek[0]}';
    print('Sending request to: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> galleryData = json.decode(response.body);

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
      _slidePanelText = text;
      _slideFromLeft = !isLeftColumn; // 반대쪽에서 슬라이드
      _showSlidePanel = true;
      _slideAnimation = Tween<Offset>(
        begin: Offset(_slideFromLeft ? -1.0 : 1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);

      // 선택한 프로젝트 데이터로 슬라이드 패널 업데이트
      final project = _fetchProjectDataByName(text);
      _updateSlidePanel(project);
    });
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

  void _closeSlidePanel() {
    _controller.reverse().then((_) {
      setState(() {
        _showSlidePanel = false;
      });
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
      backgroundColor: Color(0xFFFFF8F1),
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
                    dropdownColor: Color(0xFFFFF8F1),
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
                    _buildDeskColumn(_getWeekTexts(false), false),
                  ],
                ),
              ),
            ],
          ),
          if (_showSlidePanel)
            Positioned.fill(
              child: RawGestureDetector(
                gestures: {
                  AllowMultipleGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          AllowMultipleGestureRecognizer>(
                    () => AllowMultipleGestureRecognizer(),
                    (AllowMultipleGestureRecognizer instance) {
                      instance
                        ..onStart = (DragStartDetails details) {}
                        ..onUpdate = (DragUpdateDetails details) {
                          if ((_slideFromLeft && details.delta.dx < -10) ||
                              (!_slideFromLeft && details.delta.dx > 10)) {
                            _closeSlidePanel();
                          }
                        };
                    },
                  ),
                },
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Align(
                    alignment: _slideFromLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/see_slide_bg.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.horizontal(
                            left: _slideFromLeft
                                ? Radius.zero
                                : Radius.circular(20),
                            right: _slideFromLeft
                                ? Radius.circular(20)
                                : Radius.zero,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(_slideFromLeft ? 5 : -5, 0),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(50, 120, 50, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 이미지 영역
                                      Container(
                                        width: 250,
                                        height: 250,
                                        color: Colors.grey[300],
                                        child: _imageUrl.isNotEmpty
                                            ? Image.network(_imageUrl,
                                                fit: BoxFit.cover)
                                            : null,
                                      ),
                                      SizedBox(width: 16),
                                      // 깃헙 영역
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            Text(
                                              'Github:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              height: 80,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: _githubLink.isNotEmpty
                                                  ? GestureDetector(
                                                      onTap: () => _launchUrl(
                                                          _githubLink),
                                                      child: Text(
                                                        _githubLink,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(height: 20),
                                            // 팀원 영역
                                            Text(
                                              'Team:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              height: 60,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _teamMembers.join(', '),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // 프로젝트 소개 영역
                                  Text(
                                    'Project Overview:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 200, // Project Overview 영역 높이
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_projectOverview),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: _slideFromLeft ? null : 0,
                              right: _slideFromLeft ? 0 : null,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    _slideFromLeft
                                        ? Icons.chevron_left
                                        : Icons.chevron_right,
                                  ),
                                  onPressed: _closeSlidePanel,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: [
                Image.asset('assets/images/desk.png'),
                if (texts != null && texts.length > index)
                  Positioned(
                    bottom: 8,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _onTextTap(texts[index], isLeftColumn),
                      child: Text(
                        texts[index],
                        style: TextStyle(
                          color: Color(0xFF595959),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class AllowMultipleGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
