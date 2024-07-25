import 'package:flutter/material.dart';
import 'dart:math';

class ClockWidget extends StatefulWidget {
  final Function(double) onAngleChanged;
  final String selectedWeek;

  const ClockWidget(
      {Key? key, required this.onAngleChanged, required this.selectedWeek})
      : super(key: key);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late double _angle;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _setInitialAngle();
  }

  @override
  void didUpdateWidget(ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _setInitialAngle();
    }
  }

  void _setInitialAngle() {
    setState(() {
      if (widget.selectedWeek == '1주차') {
        _angle = (10.5 / 12) * 2 * pi; // 10시 30분 방향
      } else {
        _angle = (11 / 12) * 2 * pi; // 11시 방향
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // 시계의 크기를 줄임
      height: 100, // 시계의 크기를 줄임
      child: GestureDetector(
        onPanStart: (details) {
          _isInitialLoad = false;
          _updateAngle(details.localPosition);
        },
        onPanUpdate: (details) {
          _isInitialLoad = false;
          _updateAngle(details.localPosition);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border:
                Border.all(color: Color(0xFFB8B8B8), width: 7), // 테두리 두께와 색상 변경
          ),
          child: Stack(
            children: [
              ..._buildClockMarks(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _angle,
                      alignment: Alignment.center,
                      child: Align(
                        alignment: Alignment(0, -0.4),
                        child: Container(
                          height: 25, // 시침의 높이를 줄임
                          width: 3, // 시침의 너비를 줄임
                          decoration: BoxDecoration(
                            color: Color(0xFFB8B8B8), // 시침 색상 변경
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 6, // 중심점의 크기를 줄임
                      height: 6, // 중심점의 크기를 줄임
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFB8B8B8), // 중심점 색상 변경
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAngle(Offset localPosition) {
    final center = Offset(60, 60); // 시계의 중심점 (120x120 크기 기준)
    final vector = localPosition - center;

    // 마우스 포인터의 각도 계산
    final pointerAngle = atan2(vector.dy, vector.dx);

    // 각도를 0에서 2π 범위로 조정
    final correctedAngle = (pointerAngle + (2.5 * pi)) % (2 * pi);

    setState(() {
      _angle = correctedAngle;
    });
    if (!_isInitialLoad) {
      widget.onAngleChanged(correctedAngle);
    }
  }

  List<Widget> _buildClockMarks() {
    return List.generate(12, (index) {
      final angle = index * (2 * pi / 12);
      return Transform.rotate(
        angle: angle,
        child: Align(
          alignment: Alignment(0, -0.9),
          child: Container(
            height: 10, // 시계 눈금의 높이를 줄임
            width: 2,
            color: Color(0xFFB8B8B8), // 시계 눈금 색상 변경
          ),
        ),
      );
    });
  }
}
