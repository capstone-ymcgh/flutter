# flutter
1. 메인페이지 배치 변경 예정
2. 레시피 공유 게시판, 도매 게시판 디자인 최종 수정 완료
- 식단 추가페이지 배치 수정O, 좋아요수/댓글수 표시O, 도매 게시판 디자인 수정O
3. 레시피 공유 게시판, 도매 게시판 기능 최종 수정 예정
- 장바구니 기능 구현 완료
- 저장 기능, 필터 기능 구현중/좋아요댓글 기능 수정중

- 댓글 기능 수정해야 함(댓글 페이지 순서가 고정되어있음)
- 검색 기능도 수정해야 함(검색페이지에서 상세페이지 들어갔을 때 편집[삭제/수정] 시에 기본 페이지에는 적용이 앱을 껐다켜야 적용됨/데이터 로드(상태관리) 문제)







res파일 위치 >> C:\Androidstudio\fluttertest\android\app\src\main


pubspec.yaml이 파일에

dependencies:
  flutter:
    sdk: flutter
  syncfusion_flutter_datepicker: ^25.1.42
  shared_preferences: ^2.0.13
  image_picker: ^0.8.4+4
  provider: ^6.0.2

이거 위치 찾아서 넣으셈요
