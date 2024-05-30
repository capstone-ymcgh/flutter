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
  List<bool> selectedBoxes = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dataCount = prefs.getInt('dataCount') ?? 0; // Get the total count of saved data

    List<String> loadedTitles = [];
    List<List<DateTime>> loadedSelectedDatesList = [];
    List<Map<DateTime, List<String>>> loadedTextsList = [];
    List<bool> loadedSelectedBoxes = [];

    for (int i = 1; i <= dataCount; i++) {
      String storedTitle = prefs.getString('title$i') ?? '';
      List<String> storedSelectedDatesString = prefs.getStringList('selectedDates$i') ?? [];
      String storedTextsJson = prefs.getString('texts$i') ?? '{}';

      // Decode texts JSON string
      Map<String, dynamic> textsStringMap = jsonDecode(storedTextsJson);
      Map<DateTime, List<String>> storedTexts = textsStringMap.map(
            (key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)),
      );

      loadedTitles.add(storedTitle);
      loadedSelectedDatesList.add(storedSelectedDatesString.map((dateString) => DateTime.parse(dateString)).toList());
      loadedTextsList.add(storedTexts);
      loadedSelectedBoxes.add(false);
    }

    setState(() {
      titles = loadedTitles;
      selectedDatesList = loadedSelectedDatesList;
      textsList = loadedTextsList;
      selectedBoxes = loadedSelectedBoxes;
    });
  }

  Future<void> _deleteSelectedBoxes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> newTitles = [];
    List<List<DateTime>> newSelectedDatesList = [];
    List<Map<DateTime, List<String>>> newTextsList = [];

    for (int i = 0; i < selectedBoxes.length; i++) {
      if (!selectedBoxes[i]) {
        newTitles.add(titles[i]);
        newSelectedDatesList.add(selectedDatesList[i]);
        newTextsList.add(textsList[i]);
      }
    }

    setState(() {
      titles = newTitles;
      selectedDatesList = newSelectedDatesList;
      textsList = newTextsList;
      selectedBoxes = List.generate(titles.length, (index) => false);
    });

    await prefs.setInt('dataCount', titles.length);
    for (int i = 0; i < titles.length; i++) {
      await prefs.setString('title${i + 1}', titles[i]);
      await prefs.setStringList('selectedDates${i + 1}', selectedDatesList[i].map((date) => date.toIso8601String()).toList());
      await prefs.setString('texts${i + 1}', jsonEncode(textsList[i]));
    }
  }

  void startEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void stopEditing() {
    setState(() {
      isEditing = false;
      selectedBoxes = List.generate(titles.length, (index) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isEditing) {
          stopEditing();
          return false; // 이벤트 소비, 다른 작업이 실행되지 않도록 함
        }
        return true; // 뒤로 가기 동작 허용
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const Text('식단 리스트', style: TextStyle(color: Colors.black)),
          actions: isEditing
              ? [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.black,
              onPressed: () {
                _deleteSelectedBoxes();
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              color: Colors.black,
              onPressed: () {
                stopEditing();
              },
            ),
          ]
              : [],
        ),
        body: isEditing ? buildEditingPage() : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    if (titles.isEmpty) {
      return const Center(
        child: Text('식단을 추가해주세요'),
      );
    } else {
      return ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return _buildSelectableBox(_buildBox(index), index);
        },
      );
    }
  }

  Widget buildEditingPage() {
    return ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return _buildSelectableBox(_buildBox(index), index);
      },
    );
  }

  Widget _buildSelectableBox(Widget box, int index) {
    return GestureDetector(
      onLongPress: () {
        startEditing();
      },
      onTap: () {
        setState(() {
          if (isEditing) {
            selectedBoxes[index] = !selectedBoxes[index];
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: selectedBoxes[index] ? const Color(0xff58C58A) : Colors.transparent),
        ),
        child: box,
      ),
    );
  }

  Widget _buildBox(int index) {
    return Container(
      height: 143,
      margin: const EdgeInsets.fromLTRB(16, 7, 16, 7), //left(16or18), top8, right, bottom
      padding: const EdgeInsets.only(left: 29.5, top: 10), //박스 안 크기
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffDDDEDE), width: 3), //박스 테두리 선 굵기
        borderRadius: BorderRadius.circular(40), //박스 테두리 곡선
        boxShadow: const [
          BoxShadow( //박스 테두리 그림자
            color: Color(0xffE1E1E1),
            spreadRadius: 0.5,
            blurRadius: 1.0, //1.5
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 7.7),
                Text(
                  titles[index],
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  textsList[index].values.expand((list) => list).join(', ').length > 15
                      ? '${textsList[index].values.expand((list) => list).join(', ').substring(0, 15)}...'
                      : textsList[index].values.expand((list) => list).join(', '),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1, // 텍스트가 한 줄에 맞게 표시되도록 설정
                  overflow: TextOverflow.ellipsis, // 넘치는 텍스트는 생략 부호로 표시
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 10, top: 0),
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 63,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DietPage(selectedDatesList[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
