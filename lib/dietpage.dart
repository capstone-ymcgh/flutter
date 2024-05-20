import 'package:flutter/material.dart';
import 'calendarpage.dart';
import 'main.dart';
import 'infopage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for json encoding and decoding

class DietPage extends StatefulWidget {
  final List<DateTime> selectedDates;

  DietPage(this.selectedDates);

  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  bool _isListView = true; // 현재 보기가 일렬 보기인지 여부를 저장할 변수

  final Map<DateTime, List<String>> texts = {
    DateTime(2024, 5, 1): ['2024, 5, 1', '미역국', '흰 쌀밥', '제육볶음', '배추김치'],
    DateTime(2024, 5, 2): ['2024, 5, 2', '김치찌개', '현미밥', '오징어볶음', '무생채'],
    DateTime(2024, 6, 3): ['2024, 6, 3', '된장찌개', '보리밥', '닭볶음탕', '깍두기'],
    // 더 많은 날짜와 텍스트 추가...
  };

  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식단 페이지'),
        actions: [
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              setState(() {
                _isListView = true; // 일렬 보기로 설정
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isListView = false; // 달력 페이지 보기로 설정
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildView(), // 선택된 보기에 따라 다른 위젯 빌드
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: _showSaveDialog,
              child: Text('저장'),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.orange, // 버튼의 배경색
                padding: EdgeInsets.all(20), // 버튼의 크기를 설정
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('제목 입력'),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: '제목을 입력하세요'),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () async {
                String title = _titleController.text;
                if (title.isNotEmpty) {
                  // 제목과 함께 selectedDates와 texts 저장하는 로직 추가
                  print('저장할 제목: $title');
                  await _saveData(title);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveData(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Increment dataCount by 1
    int dataCount = (prefs.getInt('dataCount') ?? 0) + 1;
    await prefs.setInt('dataCount', dataCount);

    // Convert selectedDates to a list of strings
    List<String> selectedDatesString =
    widget.selectedDates.map((date) => date.toIso8601String()).toList();

    // Convert texts to a Map<String, List<String>> to store in SharedPreferences
    Map<String, List<String>> textsStringMap = texts.map(
          (key, value) => MapEntry(key.toIso8601String(), value),
    );

    // Encode texts map as a JSON string
    String textsJson = jsonEncode(textsStringMap);

    // Save data with the incremented dataCount
    await prefs.setString('title$dataCount', title);
    await prefs.setStringList('selectedDates$dataCount', selectedDatesString);
    await prefs.setString('texts$dataCount', textsJson);

    print('Data saved');
    print(title);
    print(selectedDatesString);
    print(textsJson);
  }

  Widget _buildView() {
    if (_isListView) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.selectedDates.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // 특정 행동을 수행하도록 설정
              print('ListTile이 눌렸습니다. 인덱스: $index');
              DateTime selectedDate = widget.selectedDates[index];
              List<String> selectedTexts = texts[selectedDate] ?? [];
              // 여기에 원하는 동작을 추가하십시오.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage(selectedTexts)),
              );
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(widget.selectedDates[index].toString().substring(0, 10)),
                  subtitle: Text(texts[widget.selectedDates[index]]?.sublist(1)?.join(', ') ?? '식단 없음'),
                ),
                Divider(
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 선택된 달의 첫 번째 날짜와 마지막 날짜 계산
      DateTime firstDay = DateTime(widget.selectedDates[0].year, widget.selectedDates[0].month, 1);
      DateTime lastDay = DateTime(widget.selectedDates[0].year, widget.selectedDates[0].month + 1, 0);

      // 일요일부터 시작하도록 계산
      DateTime firstSunday = firstDay;
      while (firstSunday.weekday != 7) {
        firstSunday = firstSunday.subtract(Duration(days: 1));
      }

      return Container(
        height: 1500, // 세로 크기를 원하는 만큼 늘림
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(), // GridView의 자체 스크롤 비활성화
          shrinkWrap: true, // GridView가 자신의 높이를 계산하도록 설정
          itemCount: lastDay.difference(firstSunday).inDays + 1, // 선택된 달의 일 수만큼 아이템 수 설정
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 한 줄에 7개의 박스
            mainAxisSpacing: 4.0, // 박스 사이의 수직 간격
            crossAxisSpacing: 4.0, // 박스 사이의 수평 간격
            childAspectRatio: 0.3, // 박스의 가로 세로 비율
          ),
          itemBuilder: (context, index) {
            // 일요일부터 시작하도록 계산
            DateTime date = firstSunday.add(Duration(days: index));

            // 선택된 달의 첫 번째 날짜부터 index만큼 더한 날짜 계산
            //DateTime date = firstDay.add(Duration(days: index));

            // 요일에 따라 출력할 텍스트 설정
            String dayOfWeek = _getDayOfWeekString(date.weekday);

            // 선택된 날짜에 해당하는 텍스트를 가져오기
            final boxTexts = texts[date] ?? [date.toString().substring(0, 10)];

            return InkWell(
              onTap: () {
                // 박스를 눌렀을 때 실행되는 동작
                print('Box $index tapped with texts: $boxTexts');
                List<String> selectedTexts = texts[date] ?? [];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoPage(selectedTexts)),
                );
              },
              child: Container(
                color: Colors.orange[200], // 박스의 배경색
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      dayOfWeek, // 요일 출력
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                    ...boxTexts.map((text) => Text(
                      text, // 각 줄에 해당하는 텍스트
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

// 요일을 숫자에서 문자열로 변환하는 함수
  String _getDayOfWeekString(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return ''; // 비어있는 요일에는 공백 문자열 반환
    }
  }
}