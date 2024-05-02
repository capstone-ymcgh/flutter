import 'package:flutter/material.dart';
import 'loginpage.dart';



class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 60),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'nickname',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      'e-mail',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // 로그아웃 확인 창을 띄우는 함수 호출
                _showLogoutConfirmationDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.grey, // 선의 색상 설정
          thickness: 1, // 선의 두께 설정
          height: 30, // 선의 높이 설정
        ),
        Text('개인정보 변경'),
        SizedBox(height: 20), // 추가적인 간격 조절
        // 닉네임 변경 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {
                _showNicknameChangeDialog(context);
              },
              child: Text('닉네임 변경',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        // 사진 변경 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {

              },
              child: Text('프로필 사진 변경',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        // 비밀번호 변경 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {

              },
              child: Text('비밀번호 변경',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        // 선 추가
        Divider(
          color: Colors.grey, // 선의 색상 설정
          thickness: 1, // 선의 두께 설정
          height: 30, // 선의 높이 설정
        ),
        Text('레시피 공유 게시판'),
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {

              },
              child: Text('작성한 글',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {

              },
              child: Text('작성한 댓글',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽으로 정렬
          children: [
            GestureDetector(
              onTap: () {

              },
              child: Text('즐겨찾기한 글',style:TextStyle(fontSize: 20)),
            ),
          ],
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        Divider(
          color: Colors.grey, // 선의 색상 설정
          thickness: 1, // 선의 두께 설정
          height: 30, // 선의 높이 설정
        ),
        SizedBox(height: 20), // 추가적인 간격 조절
        Center( // 가운데 정렬을 위해 Center 위젯 사용
          child: GestureDetector(
            onTap: () {
              _showWithdrawalConfirmationDialog(context);
            },
            child: Text(
              '회원 탈퇴',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }


  // 로그아웃 확인 창을 띄우는 함수
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('정말 로그아웃하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 취소 버튼을 눌렀을 때는 다이얼로그를 닫음
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 로그아웃 로직을 여기에 추가
                // 예를 들어 Firebase에서 로그아웃 등
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  // 회원 탈퇴 확인 창을 띄우는 함수
  void _showWithdrawalConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: Text('정말 회원 탈퇴하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 취소 버튼을 눌렀을 때는 다이얼로그를 닫음
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 회원 탈퇴 로직을 여기에 추가
                // 예를 들어 Firebase에서 사용자 데이터 삭제 등
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('회원 탈퇴'),
            ),
          ],
        );
      },
    );
  }
  void _showNicknameChangeDialog(BuildContext context) {
    String newNickname = ''; // 새로운 닉네임을 저장할 변수

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('닉네임 변경'),
          content: TextField(
            onChanged: (value) {
              newNickname = value; // 사용자가 입력한 닉네임 저장
            },
            decoration: InputDecoration(
              hintText: '새로운 닉네임을 입력해주세요',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 취소 버튼을 눌렀을 때 다이얼로그 닫기
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 확인 버튼을 눌렀을 때 새 닉네임을 적용하고 다이얼로그 닫기
                // 여기에 새 닉네임을 서버에 업데이트하는 로직을 추가할 수 있습니다.
                Navigator.of(context).pop();
                print('새로운 닉네임: $newNickname');
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}