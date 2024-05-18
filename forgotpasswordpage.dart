import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatelessWidget {
  // TextEditingController를 생성
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[300],
        title: Text('비밀번호 찾기'),
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
                controller: emailController, // TextEditingController 할당
                decoration: InputDecoration(
                  hintText: '이메일 주소 입력',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  // 입력된 이메일 주소를 가져와 변수에 저장
                  String email = emailController.text;

                  // 여기서 이메일 주소를 처리하는 로직을 추가할 수 있습니다.
                  // 예를 들어, 서버로 전송하거나 유효성 검증을 수행하는 등

                  // 비밀번호 찾기 버튼을 눌렀을 때 실행되는 동작
                  print('입력된 이메일: $email');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(
                    '비밀번호 찾기',
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
