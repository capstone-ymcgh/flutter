import 'dart:async';

import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  bool _isDietButtonClicked = false;
  bool _isRecipeButtonClicked = false;

  @override
  void initState() {
    super.initState();
    // 3초마다 자동으로 페이지를 넘기는 타이머 설정
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPageIndex < 2) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //상단 광고 배너
            Container(
              height: 200, // 광고 배너의 높이 조절
              color: Colors.grey[300], // 광고 배너의 배경색

              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    children: [
                      Container(color: Colors.blue),
                      Container(color: Colors.green),
                      Container(color: Colors.orange),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDietButtonClicked = !_isDietButtonClicked;
                          // 여기서 추가
                          if (!_isDietButtonClicked) {
                            Future.delayed(Duration(milliseconds: 100), () {
                              setState(() {
                                _isDietButtonClicked = !_isDietButtonClicked;
                              });
                            });
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: _isDietButtonClicked ? 150.0 : 140.0,
                        width: _isDietButtonClicked ? 170:180,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(35.0), // 테두리를 둥글게 만들기
                        ),
                        child: Center(
                          child: Text(
                            '식단 추가하기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRecipeButtonClicked = !_isRecipeButtonClicked;
                          // 여기서 추가
                          if (!_isRecipeButtonClicked) {
                            Future.delayed(Duration(milliseconds: 100), () {
                              setState(() {
                                _isRecipeButtonClicked = !_isRecipeButtonClicked;
                              });
                            });
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: _isRecipeButtonClicked ? 150.0 : 140.0,
                        width: _isRecipeButtonClicked ? 170 : 180,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(35.0), // 테두리를 둥글게 만들기
                        ),
                        child: Center(
                          child: Text(
                            '레시피 검색',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '도매 주문',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton('버튼 1'),
                      _buildCircularButton('버튼 2'),
                      _buildCircularButton('버튼 3'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCircularButton(String text) {
    return ElevatedButton(
      onPressed: () {
        // 버튼 동작 추가
      },
      child: Text(text),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}
