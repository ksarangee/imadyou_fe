import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:imadyou/screens/home_screen.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String? accessToken; // 전역 변수 선언
  static String currentUserName = '';
  static String currentUserFullName = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I Mad You',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class GlobalAudioPlayer {
  static final AudioPlayer player = AudioPlayer();
  static bool isPlaying = false;

  static Future<void> playBackgroundMusic() async {
    try {
      await player.setSource(AssetSource('audios/bye.mp3'));
      await player.resume();
      isPlaying = true;
    } catch (e) {
      print('Error loading audio source: $e');
    }
  }

  static Future<void> pauseBackgroundMusic() async {
    try {
      await player.pause();
      isPlaying = false;
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }
}
