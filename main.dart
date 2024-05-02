import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'profilepage.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _a = 0; // late 키워드 사용
  DateTime? currentBackPressTime;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 현재 시간을 가져옴
        DateTime now = DateTime.now();
        // 이전 뒤로가기 버튼 누른 시간이 null이 아니고 2초 이내에 눌렀으면 앱 종료
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('한 번 더 누르면 종료됩니다.'),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[300],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              // 뒤로 가기 버튼을 눌렀을 때 실행할 동작
            },
          ),
        ),
        body: Center(
          // 현재 선택된 아이템에 해당하는 텍스트를 표시
          child: _pages[_a],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.orange[300],
          selectedItemColor: Colors.black,
          // 선택된 아이템의 아이콘과 라벨 색상 설정
          unselectedItemColor: Colors.grey[300],
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
              label: '프로필',
            ),
          ],
          currentIndex: _a,
          onTap: (int index) {
            setState(() {
              _a = index;
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
                // Profile 아이템이 탭되었을 때 실행될 동작
                print('Profile item tapped!');
            }
          },
        ),
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Home Page'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 버튼을 눌렀을 때 실행되는 동작
            },
            child: Text('test'),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Favorites Page'),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
    );
  }
}



