import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _login(BuildContext context, String userName, String week1,
      String week2, String week3, String week4) async {
    final client = http.Client();
    try {
      // 요청 전 body를 JSON 문자열로 변환된거 로그로 출력
      final requestBody = jsonEncode(<String, String>{
        'user_name': userName,
        'week1': week1,
        'week2': week2,
        'week3': week3,
        'week4': week4,
      });

      print('Request body: $requestBody');

      final response = await client.post(
        Uri.parse('http://3.38.95.45/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        MyApp.accessToken = responseData['access_token'];
        MyApp.currentUserName =
            userName.length > 1 ? userName.substring(1) : userName;

        // 성공적인 응답만 로그로 출력
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        //로그인 성공 팝업
        _showSuccessPopup(context);
      } else {
        _showErrorDialog(context);
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context);
    } finally {
      client.close();
    }
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF8F1),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              "로그인 성공!",
              style: TextStyle(
                color: Color(0xFF595959),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    // 2초 후 팝업을 닫고 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 팝업 닫기
      Navigator.pushReplacementNamed(context, '/home'); // 다음 화면으로 이동
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F1),
        title: const Text('로그인 실패', style: TextStyle(color: Color(0xFF595959))),
        content: const Text('로그인 정보를 다시 확인해주세요.',
            style: TextStyle(color: Color(0xFF595959))),
        actions: <Widget>[
          TextButton(
            child: const Text('확인', style: TextStyle(color: Color(0xFF595959))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNameController = TextEditingController();
    final week1Controller = TextEditingController();
    final week2Controller = TextEditingController();
    final week3Controller = TextEditingController();
    final week4Controller = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 로그인 화면 내용
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 320.0),
              child: Row(
                children: [
                  // 웹의 이름 및 설명
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "I \nMad \nYou.",
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF484848),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Dedicated to our beloved class",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF484848),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 입력 폼 및 버튼
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 이름 입력 필드
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "이름을 입력해주세요",
                                style: TextStyle(color: Color(0xFF484848)),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: userNameController,
                                  decoration: InputDecoration(
                                    hintText: "예) 홍길동",
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 인증 입력 필드들
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "인증을 해주세요",
                                style: TextStyle(color: Color(0xFF484848)),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 300,
                                child: Column(
                                  children: [
                                    // 1주차 질문 입력 필드
                                    TextField(
                                      controller: week1Controller,
                                      decoration: InputDecoration(
                                        hintText: "1주차에 다함께 만들어 먹은 것은?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 2주차 질문 입력 필드
                                    TextField(
                                      controller: week2Controller,
                                      decoration: InputDecoration(
                                        hintText: "2주차부터 시작한 게임 이름은?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 3주차 질문 입력 필드
                                    TextField(
                                      controller: week3Controller,
                                      decoration: InputDecoration(
                                        hintText: "3주차에 간 회식 장소는?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 4주차 질문 입력 필드
                                    TextField(
                                      controller: week4Controller,
                                      decoration: InputDecoration(
                                        hintText: "4주차에 엠티로 간 장소는?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 로그인 버튼
                          ElevatedButton(
                            onPressed: () {
                              _login(
                                context,
                                userNameController.text,
                                week1Controller.text,
                                week2Controller.text,
                                week3Controller.text,
                                week4Controller.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF777A7B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            child: const Text(
                              "로그인",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
