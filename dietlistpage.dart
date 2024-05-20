import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for json encoding and decoding
import 'dietpage.dart';

class DietListPage extends StatefulWidget {
  @override
  _DietListPageState createState() => _DietListPageState();
}

class _DietListPageState extends State<DietListPage> {
  List<String> titles = [];
  List<List<DateTime>> selectedDatesList = [];
  List<Map<DateTime, List<String>>> textsList = [];


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int dataCount = prefs.getInt('dataCount') ?? 0; // Get the total count of saved data

    for (int i = 1; i <= dataCount; i++) {
      String storedTitle = prefs.getString('title$i') ?? '';
      List<String> storedSelectedDatesString = prefs.getStringList('selectedDates$i') ?? [];
      String storedTextsJson = prefs.getString('texts$i') ?? '{}';

      // Decode texts JSON string
      Map<String, dynamic> textsStringMap = jsonDecode(storedTextsJson);
      Map<DateTime, List<String>> storedTexts = textsStringMap.map(
            (key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)),
      );

      setState(() {
        titles.add(storedTitle);
        selectedDatesList.add(storedSelectedDatesString.map((dateString) => DateTime.parse(dateString)).toList());
        textsList.add(storedTexts);
      });

      print('Data loaded for title$i');
      print(storedTitle);
      print(selectedDatesList.last);
      print(textsList.last);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text('식단 리스트'),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    if (titles.isEmpty) {
      return Center(
        child: Text('식단을 추가해주세요'),
      );
    } else {
      return ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('식단 제목: ${titles[index]}'),
              onTap: () {
                // 버튼을 눌렀을 때 실행되는 동작
                print('확인 버튼이 눌렸습니다.');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DietPage(selectedDatesList[index]),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}
