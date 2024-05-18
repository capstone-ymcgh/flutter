import 'package:flutter/material.dart';
import 'calendarpage.dart';
import 'main.dart';
import 'infopage.dart';

class DietPage extends StatefulWidget {
  final List<DateTime> selectedDates;

  DietPage(this.selectedDates);

  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  bool _isListView = true; // 현재 보기가 일렬 보기인지 여부를 저장할 변수

  // 박스마다 다른 텍스트를 설정하기 위한 리스트
  final List<List<String>> texts = [
    ['8/1'],
    ['8/2', '미역국', '흰 쌀밥', '제육볶음', '배추김치'],
    ['Box 3', 'Line 1', 'Line 2'],
    ['Box 4', 'Line 1', 'Line 2'],
    ['Box 5', 'Line 1', 'Line 2'],
    ['Box 6', 'Line 1', 'Line 2'],
    ['Box 7', 'Line 1', 'Line 2'],
    ['Box 8', 'Line 1', 'Line 2'],
    ['Box 9', 'Line 1', 'Line 2'],
    ['Box 10', 'Line 1', 'Line 2'],
    ['Box 11', 'Line 1', 'Line 2'],
    ['Box 12', 'Line 1', 'Line 2'],
    ['Box 13', 'Line 1', 'Line 2'],
    ['Box 14', 'Line 1', 'Line 2'],
    ['Box 15', 'Line 1', 'Line 2'],
    ['Box 16', 'Line 1', 'Line 2'],
    ['Box 17', 'Line 1', 'Line 2'],
    ['Box 18', 'Line 1', 'Line 2'],
    ['Box 19', 'Line 1', 'Line 2'],
    ['Box 20', 'Line 1', 'Line 2'],
    ['Box 21', 'Line 1', 'Line 2'],
    ['Box 22', 'Line 1', 'Line 2'],
    ['Box 23', 'Line 1', 'Line 2'],
    ['Box 24', 'Line 1', 'Line 2'],
    ['Box 25', 'Line 1', 'Line 2'],
    ['Box 26', 'Line 1', 'Line 2'],
    ['Box 27', 'Line 1', 'Line 2'],
    ['Box 28', 'Line 1', 'Line 2'],
    ['Box 29', 'Line 1', 'Line 2'],
    ['Box 30', 'Line 1', 'Line 2'],
    ['Box 31', 'Line 1', 'Line 2'],
    ['Box 32', 'Line 1', 'Line 2'],
    ['Box 33', 'Line 1', 'Line 2'],
    ['Box 34', 'Line 1', 'Line 2'],
    ['Box 35', 'Line 1', 'Line 2'],
    ['Box 36', 'Line 1', 'Line 2'],
    ['Box 37', 'Line 1', 'Line 2'],
    ['Box 38', 'Line 1', 'Line 2'],
    ['Box 39', 'Line 1', 'Line 2'],
    ['Box 40', 'Line 1', 'Line 2'],
    ['Box 41', 'Line 1', 'Line 2'],
    ['Box 42', 'Line 1', 'Line 2'],
  ];

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
              onPressed: () {
                // 버튼을 눌렀을 때 실행되는 동작
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
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
              // 여기에 원하는 동작을 추가하십시오.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(widget.selectedDates[index].toString().substring(0, 10)),
                  subtitle: Text('메뉴 텍스트'),
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
      return Container(
        height: 1500, // 세로 크기를 원하는 만큼 늘림
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(), // GridView의 자체 스크롤 비활성화
          shrinkWrap: true, // GridView가 자신의 높이를 계산하도록 설정
          itemCount: texts.length, // 7x5 그리드를 위해 35개의 아이템
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 한 줄에 7개의 박스
            mainAxisSpacing: 4.0, // 박스 사이의 수직 간격
            crossAxisSpacing: 4.0, // 박스 사이의 수평 간격
            childAspectRatio: 0.3, // 박스의 가로 세로 비율 (비율을 줄이면 세로가 늘어남)
          ),
          itemBuilder: (context, index) {
            // 각 박스에 대해 다른 텍스트를 설정
            final boxTexts = texts[index];
            return InkWell(
              onTap: () {
                // 박스를 눌렀을 때 실행되는 동작
                print('Box $index tapped with texts: $boxTexts');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoPage()),
                );
              },
              child: Container(
                color: Colors.orange[300], // 박스의 배경색
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: boxTexts
                      .map(
                        (text) => Text(
                      text, // 각 줄에 해당하는 텍스트
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  )
                      .toList(),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}