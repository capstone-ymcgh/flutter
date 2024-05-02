import 'package:flutter/material.dart';
import 'main.dart';
import 'singuppage.dart';
import 'forgotpasswordpage.dart';



//로그인 페이지
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text('Login'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '이메일',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                    hintText: '비밀번호',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility_off)),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 버튼을 눌렀을 때 실행되는 동작
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격 추가
                  GestureDetector(
                    onTap: () {
                      // 버튼을 눌렀을 때 실행되는 동작
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                  Spacer(), // 나머지 공간을 차지하도록 설정
                  GestureDetector(
                    onTap: () {
                      // 버튼을 눌렀을 때 실행되는 동작
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}