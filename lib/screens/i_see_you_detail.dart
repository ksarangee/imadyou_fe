import 'package:flutter/material.dart';

class ISeeYouDetailPage extends StatefulWidget {
  const ISeeYouDetailPage({super.key});

  @override
  _ISeeYouDetailPageState createState() => _ISeeYouDetailPageState();
}

class _ISeeYouDetailPageState extends State<ISeeYouDetailPage> {
  String _selectedWeek = '1주차';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: _selectedWeek,
          items: <String>['1주차', '2주차', '3주차'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedWeek = newValue!;
            });
          },
        ),
      ),
    );
  }
}
