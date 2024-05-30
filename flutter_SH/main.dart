import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'loginpage.dart';
import 'profilepage.dart';
import 'calendarpage.dart';
import 'dietlistpage.dart';
import 'RecipeSharedPage.dart';
import 'ProductOrderPage.dart';

// Import the necessary files for BoxListProvider and other components
import 'box_list_provider.dart';

void main() {
  runApp(AppProvider(child: MyApp()));
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
  final int initialIndex;

  MyHomePage({this.initialIndex = 0}); // 초기 인덱스를 받을 수 있도록 수정
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _a = 0; // late 키워드 사용
  DateTime? currentBackPressTime;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기 인덱스를 설정
  }


  final List<Widget> _pages = [
    DietListPage(),
    InputPage(),
    RecipeSharedPage(),
    ProductOrderPage(),
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
        exit(0); // 앱 종료
      },

      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.orange[300],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[300],
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
              icon: Icon(Icons.store),
              label: '도매',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '프로필',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}