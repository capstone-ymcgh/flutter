import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //날짜 포맷 패키지
import 'package:shared_preferences/shared_preferences.dart'; //데이터 영속성 패키지
import 'dart:convert'; //JSON 데이터 직렬화 및 역직렬화 패키지

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),

    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _a = 0; // late 키워드 사용, 현재 선택된 페이지의 인덱스를 저장하는 변수

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    settingPage(),
  ]; // 각 탭에 해당하는 페이지 위젯을 저장하는 리스트

  // 각 아이템이 탭되었을 때의 동작을 정의하는 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 현재 선택된 아이템에 해당하는 텍스트를 표시
        child: _pages[_a],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff58C58A),
        // 선택된 아이템의 아이콘과 라벨 색상 설정
        unselectedItemColor: Color(0xff818582),
        // 선택되지 않은 아이템의 아이콘과 라벨 색상 설정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: '식단 만들기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: '레시피',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '더보기',
          ),
        ],
        currentIndex: _a,
        onTap: (int index) {
          setState(() {
            _a = index; // 선택된 페이지 인덱스 업데이트
          });
          switch (index) {
            case 0:
              print('Home item tapped!');
            case 1:
            // Search 아이템이 탭되었을 때 실행될 동작
              print('Search item tapped!');
            case 2:
            // Favorites 아이템이 탭되었을 때 실행될 동작
              print('Favorites item tapped!');
            case 3:
            // setting 아이템이 탭되었을 때 실행될 동작
              print('setting item tapped!');
          }
        },
      ),
    );
  }
}

//각 페이지 위젯들을 별도의 클래스로 분리하여 정의
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Meal {
  String title; //식단제목
  String description; //레시피 소개

  // 객체 생성자 정의
  Meal({required this.title, required this.description});

  // JSON 형식으로 변환하는 팩토리 메서드
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(title: json['title'], description: json['description']);
  }

  // JSON으로 직렬화하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

//홈페이지의 상태를 관리하는 클래스
class _HomePageState extends State<HomePage> {
  late List<Widget> boxes = []; //상자 위젯 리스트
  late DateTime boxCreationDate; //상자 생성 날짜
  late List<Meal> meals = []; //식단 리스트

  // 추가된 박스를 저장하는 리스트(shared_preferences)
  List<bool> selectedBoxes = [];

  //상태 초기화 및 메모리에 올리기
  _HomePageState() {
    loadBoxes(); //박스 데이터 불러오기
    boxCreationDate = DateTime.now(); // 현재 시간으로 초기화
    loadMeals(); // 식단 데이터 불러오기
    boxCreationDates = []; // 리스트 초기화
  }

  @override
  void initState() {
    super.initState();
    loadBoxes(); // 박스 데이터 불러오기
    loadMeals(); // 식단 데이터 불러오기
  }

  @override
  void dispose() {
    super.dispose();
    saveBoxes(); // 앱이 종료될 때 박스 데이터 저장
    saveMeals(); // 앱이 종료될 때 식단 데이터 저장
  }
  
  //사용자가 작성한 식단을 추가
  void addMeal(Meal meal){
    setState(() {
      meals.add(meal);
      saveMeals(); // 변경된 데이터를 저장
    });
  }

  // 사용자가 추가한 식단 정보 저장
  Future<void> saveMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> mealList = meals.map((meal) => json.encode(meal.toJson())).toList();
    await prefs.setStringList('meals', mealList);
    //toJson() 사용: Meal 객체를 JSON 형식으로 직렬화
    //json.encode(): 문자열로 변환하고 리스트로 모아서 저장
  }

  // 저장된 식단 불러오기
  Future<void> loadMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? mealList = prefs.getStringList('meals');
    if (mealList != null) {
      setState(() {
        meals =
            mealList.map((jsonString) => Meal.fromJson(json.decode(jsonString)))
                .toList();
        //각 식단 정보를 JSON 형식에서 Meal 객체로 역직렬화, 리스트로 변환하여 meals 변수에 할당
      });
    }
  } /*SharedPreferences는 안드로이드 및 iOS에서 사용자의 데이터를 영구적으로 저장하고 검색하는 데
   사용되는 키-값 쌍 저장소임. 이를 통해 간단한 데이터(예: 설정, 프로필 정보, 사용자 환경설정 등)를
   로컬에 저장하고 가져올 수 있음. (사용자 설정 및 환경설정 관리/사용자 데이터 저장/세션 관리)
   앱이 종료되어도 SharedPreferences에 저장된 데이터는 영구적으로 유지되므로,
   사용자 경험을 향상시키고 사용자가 앱을 다시 열 때 이전 상태를 복원하는 데 유용
  */

  // SecondPage로 이동하며 식단 정보 전달
  void navigateToSecondPage(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage(meal: meal)),
    );
  }

  // 박스 추가
  void addBox() {
    setState(() {
      // 새로운 상자에 대한 선택 항목을 추가
      boxes.add(_buildBox(boxes.length));
      selectedBoxes.add(false);
      // 새로운 상자를 추가할 때의 날짜를 저장
      DateTime boxCreationDate = DateTime.now();
      // 박스의 인덱스와 함께 생성 날짜를 저장
      boxCreationDates.add(boxCreationDate);
      saveBoxes();
    });
  }

// 박스 추가/삭제 시 상태를 저장하고 불러오기 위한 함수들
  Future<void> loadBoxes() async { //이전에 저장된 박스 데이터를 불러와서 앱 현재 상태 반영
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? boxList = prefs.getStringList('boxes'); //boxes 라는 키로 저장된 값(박스 목록)을 가져옴
    if (boxList != null) { //null이 아닌 경우 상태를 업데이트 함
      setState(() {
        boxes = boxList.map((box) => _buildBox(int.parse(box))).toList();
        // boxList에 있는 각 문자열은 _builBox() 함수를 호출하여 해당하는 위젯으로 변환되어 boxes 리스트에 추가
        selectedBoxes = List.generate(boxes.length, (index) => false);
        //selectedBoxes 리스트를 박스 수 만큼 생성하여 초기화

        // boxCreationDates 초기화
        boxCreationDates = [];
        // 저장된 상자들의 생성 날짜를 불러옵니다.
        for (int i = 0; i < boxes.length; i++) {
          DateTime? boxDate = DateTime.parse(
            prefs.getString('boxDate$i') ?? '',
          );
          if (boxDate != null) {
            boxCreationDates.add(boxDate); //각 상자의 생성날짜를 boxCreationDates 리스트에 추가
          }
        }
      });
    }
  }

  Future<void> saveBoxes() async { // 현재 상태의 박스 데이터를 SharedPreferences에 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> boxList = boxes.map((box) => boxes.indexOf(box).toString())
        .toList(); //boxes 리스트를 순회하면서 각 박스의 인덱스를 문자열로 변환하여 boxList에 추가
    await prefs.setStringList('boxes', boxList); //boxes 키에 boxList 저장
    
    // 박스가 저장될 때 생성된 날짜도 함께 저장
    for (int i = 0; i < boxCreationDates.length; i++) {
      await prefs.setString('boxDate$i', boxCreationDates[i].toString());
      // boxCreationDates 리스트를 순회하면서 각각의 날자를 boxDate$i 인덱스 키로 저장
    }
  }

  bool isEditing = false; //현재 편집 모드인지 아닌지를 나타내는 부울 변수 값

  // 추가된 박스들의 생성 날짜를 관리하기 위한 리스트
  List<DateTime> boxCreationDates = [];

  // 박스 위젯을 생성(편집 모드)
  Widget _buildSelectableBox(Widget box, int index) {
    return GestureDetector(
      onLongPress: () {
        startEditing();
      },
      onTap: () {
        setState(() {
          // 편집 모드에서만 선택 토글을 발생시킴
          if (isEditing) {
            if (selectedBoxes[index]) {
              selectedBoxes[index] = false; // 선택 해제
            } else {
              selectedBoxes[index] = true; // 선택
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: selectedBoxes[index] ? Color(0xff58C58A) : Colors.transparent),
        ),
        child: box,
      ),
    );
  }

  void _deleteSelectedBoxes() {
    setState(() {
      for (int i = selectedBoxes.length - 1; i >= 0; i--) {
        if (selectedBoxes[i]) {
          // SharedPreferences에서 해당 데이터를 삭제
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('boxDate$i');
            // 삭제된 박스에 대한 식단 데이터도 삭제
            meals.removeAt(i);
            saveMeals(); // 변경된 데이터를 저장
          });
          // 선택된 박스를 삭제
          boxes.removeAt(i);
          selectedBoxes.removeAt(i);
        }
      }
      meals.clear();
      saveBoxes(); // 변경된 박스 데이터를 저장
      stopEditing(); // 삭제 후에 편집 모드를 종료함
    });
  }
  //meals.clear(); // 식단 목록 초기화

  @override
  Widget build(BuildContext context) { //위젯 트리 생성
    return isEditing ? buildEditingPage() : buildMainPage(); //삼항 연산자
    /*만약 isEditing이 true이면 buildEditingPage() 메서드가 호출되어 편집 모드를 표시하는 위젯을 반환.
    그렇지 않으면 buildMainPage() 메서드가 호출되어 일반적인 메인 화면을 표시하는 위젯을 반환.*/
    /*이러한 구조를 통해 앱은 사용자가 편집 모드로 전환하거나 일반 모드로 전환할 때 마다 해당하는 위젯을 동적으로 변경 가능*/
  }

  Widget buildMainPage() {
    // 상자가 없을 때 "식단을 추가해보세요"를 표시하고, 있을 때는 상자를 표시합니다.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 119, top: 0),
          child: Text(
            '식단 추가하기',
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
        ),
        actions: <Widget>[
          Positioned(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealPage(
                      onSave: (meal) {
                        addMeal(meal);
                        addBox();
                      },
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 36,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => noticePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0), // 위쪽 여백 추가
        child: Container(
          color: Colors.white, // 배경색 설정
          child: Stack(
            children: [
              // 박스가 없을 때 "식단을 추가해보세요"를 표시합니다.
              if (boxes.isEmpty)
                Center(
                  child: Text(
                    '식단을 추가해보세요',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              // 박스가 있을 때 상자를 표시합니다.
              if (boxes.isNotEmpty)
                Positioned.fill(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 12, bottom: 25.6), //2.2, 18.6
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      return _buildSelectableBox(boxes[index], index);
                      },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditingPage() {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기를 눌렀을 때 편집 모드를 종료하고 원래 페이지로 이동
        stopEditing();
        return false; // 뒤로 가기 이벤트를 소비하여 다른 작업이 실행되지 않도록 함
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.only(left: 145.9, top: 0),
            child: Text(
              '선택 삭제',
              style: TextStyle(fontSize: 25, color: Colors.black),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete_outline), iconSize: 33,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('삭제'),
                      content: Text(
                          '식단 목록을 삭제하시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xff58C58A)), // Cancel 버튼 색상 변경
                          ),

                        ),
                        TextButton(
                          onPressed: () {
                            _deleteSelectedBoxes();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Color(0xff58C58A)), // Cancel 버튼 색상 변경
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: boxes.length,
          itemBuilder: (context, index) {
            return _buildSelectableBox(boxes[index], index);
          },
        ),
      ),
    );
  }

  void startEditing() { //편집 모드 시작
    setState(() {
      isEditing = true;
    });
  }

  void stopEditing() { //편집 모드 종료
    setState(() {
      isEditing = false;
      // 선택한 박스들을 모두 해제
      selectedBoxes = List.generate(boxes.length, (index) => false);
    });
  }

  Widget _buildBox(int index) {
    Meal meal = meals.isNotEmpty ? meals[index % meals.length] : Meal(title: '', description: '');

    return Container(
      height: 143,
      margin: EdgeInsets.fromLTRB(16, 7, 16, 7), //left(16or18), top8, right, bottom
      padding: EdgeInsets.only(left: 29.5, top: 10), //박스 안 크기
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffDDDEDE), width: 3), //박스 테두리 선 굵기
        borderRadius: BorderRadius.circular(40), //박스 테두리 곡선
        boxShadow: [
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
                SizedBox(height: 7.7),
                Text(
                  DateFormat('yyyy-MM-dd').format(boxCreationDate),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.25),
                Text(
                  meal.title,
                  style: TextStyle(fontSize: 19),
                ),
                SizedBox(height: 3),
                Text(
                  meal.description,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 10, top: 0),
            child: IconButton(
              icon: Icon(Icons.chevron_right),
              iconSize: 63,
              onPressed: () {
                navigateToSecondPage(meal);
              },
            ),
          ),
        ],
      ),
    );
  }
}

//박스를 길게 눌렀을 경우
class LongPressPopup extends StatelessWidget {
  final Function(String) onSelection; //LongPressPopup의 필수 매개변수: 팝업 메뉴에서 선택된 항목에 대한 콜백 함수
  final Widget child; //LongPressPopup의 필수 매개변수: 팝업을 띄울 위젯

  LongPressPopup({required this.onSelection, required this.child}); //생성자

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //길게 눌렀을 때 팝업 창을 표시하는 기능 수행
      onLongPress: () {
        // 꾹 눌렀을 때 팝업 창 표시
        showPopupMenu(context);
      },
      child: child,
    );
  }

  void showPopupMenu(BuildContext context) async { //팝업창을 표시하는 비동기 함수
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(Offset.zero),
          overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
        ),
        Offset.zero & overlay.size,
      ),
      /* 현재 context의 overlay를 찾아서 팝업 창의 위치를 계산하고,
      showMenu() 함수를 사용하여 팝업 메뉴 표시함. 팝업 메뉴에는 삭제 옵셥만 포함되어 있음.*/

      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Delete',
          child: Text('Delete'),
        ),
      ],
    );

    if (selected != null) {
      onSelection(selected); //사용자가 팝업 메뉴에서 항목 선택 시 선택된 항목이 onSeletion() 콜백 함수에 전달됨
    }
  }
}

/* 나머지 페이지들*/
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // 뒤로 가기 버튼을 눌렀을 때 실행할 동작
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // 알림 아이콘 버튼을 눌렀을 때 실행할 동작
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Favorites Page'),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, //0xff00DA3D
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // 뒤로 가기 버튼을 눌렀을 때 실행할 동작
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // 알림 아이콘 버튼을 눌렀을 때 실행할 동작
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3, // 3x3 grid
        crossAxisSpacing: 8.0, // Horizontal spacing between grid items
        mainAxisSpacing: 8.0, // Vertical spacing between grid items
        children: [
          Image.network(
            'https://img.freepik.com/free-photo/top-view-of-grilled-prawns-garnished-with-pickles-and-flowers_140725-1464.jpg?size=626&ext=jpg',
            width: 150,
            height: 150,
          ),
          Image.network(
            'https://img.freepik.com/free-photo/high-angle-of-jelly-candies-on-plate-with-spoon_23-2148691431.jpg?size=626&ext=jpg',
            width: 150,
            height: 150,
          ),
          Image.network(
            'https://img.freepik.com/free-photo/meat-salad-with-vegetables-on-the-table_140725-7398.jpg?size=626&ext=jpg',
            width: 150,
            height: 150,
          ),
        ],
      ),
    );
  }
}

class settingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // 뒤로 가기 버튼을 눌렀을 때 실행할 동작
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // 알림 아이콘 버튼을 눌렀을 때 실행할 동작
            },
          ),
        ],
      ),
      body: Center(
        child: Text('setting Page'),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final Meal meal;

  SecondPage({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '식단 제목:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              meal.title,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              '레시피 간략 소개:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              meal.description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMealPage extends StatelessWidget {
  final Function(Meal) onSave;

  AddMealPage({required this.onSave});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String description = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('식단 추가하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: '식단 제목',
              ), // 기본 텍스트 색상 설정),
              onChanged: (value) => title = value,

            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: '레시피 간략 소개'),
              onChanged: (value) => description = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Meal meal = Meal(title: title, description: description);
                onSave(meal); // 새로운 식단을 onSave 콜백을 통해 전달
                Navigator.pop(context); // AddMealPage에서 뒤로 가기
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색 설정
                shadowColor: Colors.black, // 그림자 색상 설정
                elevation: 2, // 그림자 높이 설정
              ),
              child: Text(
                '저장하기',
                style: TextStyle(
                  color: Color(0xff58C58A), // 텍스트 색상 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class noticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 102.7, top: 0),
          child: Text(
            '알림창',
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
        ),
        actions: <Widget>[
          //아이콘 추가 가능
        ],
    ),
      body: Center(
        child: Text('notice Page'),
      ),
    );
  }
}
