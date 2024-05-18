import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식단 정보 및 수정'),
        backgroundColor: Colors.orange[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoText(
              text: 'Text 1',
              onTap: () {
                // Text 1이 눌렸을 때 실행되는 동작
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text 1 clicked')),
                );
              },
            ),
            SizedBox(height: 16.0),
            InfoText(
              text: 'Text 2',
              onTap: () {
                // Text 2이 눌렸을 때 실행되는 동작
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text 2 clicked')),
                );
              },
            ),
            SizedBox(height: 16.0),
            InfoText(
              text: 'Text 3',
              onTap: () {
                // Text 3이 눌렸을 때 실행되는 동작
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text 3 clicked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  InfoText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}