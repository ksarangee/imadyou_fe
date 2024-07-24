import 'package:flutter/material.dart';
import '../main.dart';

class MusicControlButton extends StatefulWidget {
  const MusicControlButton({Key? key}) : super(key: key);

  @override
  _MusicControlButtonState createState() => _MusicControlButtonState();
}

class _MusicControlButtonState extends State<MusicControlButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(GlobalAudioPlayer.isPlaying ? Icons.music_note : Icons.music_off),
      onPressed: () async {
        if (GlobalAudioPlayer.isPlaying) {
          await GlobalAudioPlayer.pauseBackgroundMusic();
        } else {
          await GlobalAudioPlayer.playBackgroundMusic();
        }
        setState(() {});
      },
      iconSize: 32,
      color: Colors.black,
    );
  }
}