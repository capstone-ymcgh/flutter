import 'package:flutter/material.dart';
import 'loginpage.dart';


class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingHeight = screenHeight * 0.1;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.orange[300],
        title: Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: paddingHeight),
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
                controller: emailController,
                decoration: InputDecoration(
                  hintText: '이메일',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  hintText: '닉네임',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  hintText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  // 입력된 값을 가져와 변수에 저장
                  String email = emailController.text;
                  String nickname = nicknameController.text;
                  String password = passwordController.text;
                  String confirmPassword = confirmPasswordController.text;

                  // 여기서 입력값을 처리하는 로직을 추가할 수 있습니다.
                  // 예를 들어, 서버로 전송하거나 폼 검증을 수행하는 등
                  print(email +','+ nickname+',' + password+',' + confirmPassword);
                  // 버튼을 눌렀을 때 실행되는 동작
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
