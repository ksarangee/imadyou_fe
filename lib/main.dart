import 'package:flutter/material.dart';
import 'package:imadyou/screens/home_screen.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String? accessToken; // 전역 변수 선언

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
