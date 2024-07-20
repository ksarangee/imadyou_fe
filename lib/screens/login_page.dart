import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                                  decoration: InputDecoration(
                                    hintText: "예) 홍길동",
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.6),
                                    //border: const OutlineInputBorder(),
                                    border: InputBorder.none,
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
                                      decoration: InputDecoration(
                                        hintText: "1주차에 다함께 만들어 먹은 것은?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        //border: const OutlineInputBorder(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 2주차 질문 입력 필드
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "2주차부터 시작한 게임 이름은?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        //border: const OutlineInputBorder(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 3주차 질문 입력 필드
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "3주차에 간 회식 장소는?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        //border: const OutlineInputBorder(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 4주차 질문 입력 필드
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "4주차에 엠티로 간 장소는?",
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.6),
                                        //border: const OutlineInputBorder(),
                                        border: InputBorder.none,
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
                              Navigator.pushReplacementNamed(context, '/home');
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
