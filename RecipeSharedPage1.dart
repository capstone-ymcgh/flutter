import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

import 'comment_icons.dart';
import 'package:provider/provider.dart';



// 작성된 시간을 가져와서 표시하는 함수
String displayDateTime(DateTime postDateTime) {
  final now = DateTime.now();
  final difference = now.difference(postDateTime);

  // 작성된 시간과 현재 시간의 차이를 확인하여 올바르게 표시
  if (difference.inDays > 0) {
    /*// 1일 이상이면 "n일 전" 형식으로 표시
      return '${difference.inDays}일 전';*/
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(postDateTime);
  } else if (difference.inHours > 0) {
    // 1시간 이상이면 "n시간 전" 형식으로 표시
    return '${difference.inHours}시간 전';
  } else if (difference.inMinutes > 0) {
    // 1분 이상이면 "n분 전" 형식으로 표시
    return '${difference.inMinutes}분 전';
  } else {
    // 1분 미만이면 방금 전으로 표시
    return '방금 전';
  }
}



class RecipeSharedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 공유'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 28,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeSearchPage(boxList: [],)),
              );
              // 검색 아이콘 버튼을 눌렀을 때 실행할 동작
            },
          ),
        ],
      ),
      body: BoxGrid(),
    );
  }
}

class BoxItem {
  late String? title; //글 제목
  late String? ingredient; //레시피재료
  late String? content; //글 작성내용
  late String? imagePath; // 글 이미지
  final DateTime postDate; //글 작성일자
  int likeCount; // 좋아요 수 필드
  final int id; // 게시물을 식별하는 고유한 식별자
  List<String> comments; // 새로운 댓글페이지

  BoxItem({
    this.title,
    this.ingredient,
    this.content,
    this.imagePath,
    required this.postDate,
    this.likeCount = 0, //기본값은 0으로 설정
    required this.id,
    List<String>? comments, // Nullable 댓글 목록
  }) : comments = comments ?? []; // 댓글 목록 초기화

  // JSON 데이터를 BoxItem 객체로 변환하는 메서드
  factory BoxItem.fromJson(Map<String, dynamic> json) {
    return BoxItem(
      title: json['title'],
      ingredient: json['ingredient'],
      content: json['content'],
      imagePath: json['imagePath'],
      postDate: DateTime.parse(json['postDate']),
      id: 1, // JSON에서 DateTime으로 변환
    );
  }

  // BoxItem 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ingredient': ingredient,
      'content': content,
      'imagePath': imagePath,
      'postDate': postDate.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
    };
  }
}

// provider 상태관리
class BoxListProvider extends ChangeNotifier {
  List<BoxItem> _boxList = [];

  List<BoxItem> get boxList => _boxList;

  void setBoxList(List<BoxItem> newList) {
    _boxList = newList;
    notifyListeners(); // 상태가 변경됨을 Provider에 알림
  }
}

//레시피 공유게시판 메인
class BoxGrid extends StatefulWidget {
  @override
  _BoxGridState createState() => _BoxGridState();
}

class _BoxGridState extends State<BoxGrid> {
  List<BoxItem> boxList = [];
  //여러 BoxItem 객체들을 담는 리스트인 boxList를 선언

  // 앱 시작시 데이터 로드
  @override
  void initState() {
    super.initState();
    loadBoxList();
  }

  // 데이터 불러오기
  Future<void> loadBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = prefs.getString('boxList');
    if (boxListJson != null) {
      setState(() {
        boxList = (json.decode(boxListJson) as List<dynamic>)
            .map((e) => BoxItem.fromJson(e))
            .toList();
        boxList.sort((a, b) => b.postDate.compareTo(a.postDate)); // 역순으로 정렬
      });
    }
  }

  // 데이터 저장하기
  Future<void> saveBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = json.encode(boxList.map((e) => e.toJson()).toList());
    await prefs.setString('boxList', boxListJson);
  }

  Future<void> _refreshData() async {
    // 여기서 필터링된 목록을 다시 계산하고 업데이트합니다.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoxListProvider(), // Provider 생성
      child: _buildBoxGrid(), // BoxGrid를 감싸고 있는 위젯
    );
  }

  @override
  Widget _buildBoxGrid() {
    return Consumer<BoxListProvider>(
        builder: (context, boxListProvider, _){
          return RefreshIndicator( //새로고침을 위함
            onRefresh: _refreshData,
            child: Stack(
              children: [
                SingleChildScrollView( //스크롤을 가능하게 함
                  physics: AlwaysScrollableScrollPhysics(), //당겨서 새로고침
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 20),
                          //상단바 (필터 페이지로 이동)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilterPage()),
                              );
                              // Handle sorting action
                            },
                            icon: Icon(Icons.expand_more),
                            label: Text('정렬'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.0, color: Color(0xff4ECB71)), // 테두리 색상 변경
                            ),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilterPage()),
                              );
                              // Handle category action
                            },
                            icon: Icon(Icons.expand_more),
                            label: Text('연령대'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.0, color: Color(0xff4ECB71)), // 테두리 색상 변경
                            ),
                          ),
                        ],
                      ),
                      //박스 디자인
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2.0, // 박스 간의 상하 간격
                          crossAxisSpacing: 0.0, // 박스 간의 좌우 간격
                          childAspectRatio: 0.46,
                        ),
                        itemCount: boxList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final postDateTime = boxList[index].postDate;
                          final showDateTime = displayDateTime(
                              postDateTime); // 작성된 시간을 표시하는 함수 호출
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage( //해당 페이지에서 게시물 페이지로 이동시에 작업
                                    boxItem: boxList[index],
                                    boxIndex: index,
                                    onDelete: (deletedBox) { //편집모드 삭제
                                      setState(() {
                                        boxList.remove(deletedBox);
                                        saveBoxList();
                                      });
                                      Navigator.pop(context); // 상세 페이지 닫기
                                      _refreshData();
                                    },
                                    onEdit: (editedBox, index) { //편집모드 수정
                                      setState(() {
                                        boxList[index] = editedBox;
                                        saveBoxList();
                                      });
                                      Navigator.pop(context);
                                      _refreshData();
                                    }, boxList: [], commentPages: [],
                                  ),
                                ),
                              );
                              // 편집 후에 박스 변경
                              if (result != null && result is WritePageResult) {
                                setState(() {
                                  boxList.insert(0, BoxItem(
                                    title: result.title,
                                    ingredient: result.ingredient,
                                    content: result.content,
                                    imagePath: result.imagePath,
                                    postDate: DateTime.now(),
                                    id: 1,
                                  ));
                                  boxList.sort((a, b) => b.postDate.compareTo(a.postDate)); // 역순으로 정렬
                                });
                                saveBoxList();
                              }
                            },
                            //박스 배치
                            child: Container(
                              margin: EdgeInsets.fromLTRB(3, 3, 3, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0), //테두리 각도
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow( //박스 그림자
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 10.5 / 13.0, //박스 이미지 비율
                                        child: boxList[index].imagePath != null
                                            ? Image.file(
                                          File(boxList[index].imagePath!),
                                          fit: BoxFit.cover,
                                        )
                                            : Image.asset(
                                          'assets/not_food_image.png',
                                          fit: BoxFit.cover,
                                        ), // 박스 이미지가 없다면 not_food_image 대체
                                      ),
                                      Positioned( // 박스 상단
                                        top: -6.0,
                                        left: 8.0,
                                        child: Row(
                                          children: [
                                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Text(
                                                '연령대',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 50.0),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => StoragePage()),
                                                );
                                                // 우측 상단 아이콘 동작
                                              },
                                              icon: Icon(Icons.bookmark_border),
                                              iconSize: 29,
                                              color: Color(0xff4ECB71),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded( //박스 하단
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          11.0, 8.0, 16.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          //작성자(기본페이지)
                                          const SizedBox(height: 2.0),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/profile_image.png',
                                                width: 22.0,
                                              ),
                                              SizedBox(width: 3.0),
                                              Text(
                                                '작성자',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          //글 제목(기본페이지)
                                          const SizedBox(height: 9.0),
                                          Text(
                                            boxList[index].title ?? 'Title', //박스 마다 제목 지정
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          //작성일자(기본페이지)
                                          const SizedBox(height: 2.0),
                                          Text(
                                            showDateTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 0.0),
                                        child: IconButton(
                                          onPressed: () {
                                            // 좌측 하단 아이콘 동작
                                          },
                                          icon: Icon(Icons.favorite_border), //좋아요 버튼
                                          iconSize: 20,
                                          color: Color(0xff4ECB71),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 0.0, top: 1.3, left: 9),
                                        child: Image.asset(
                                          'assets/comment_image.png', //댓글 버튼(이미지)
                                          fit: BoxFit.cover,
                                          width: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding( // 레시피 작성 버튼
                  padding: const EdgeInsets.fromLTRB(327, 500, 0, 0),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WritePage(), // 글작성페이지로 이동
                        ),
                      );
                      // 글 작성 후에 박스 추가(역순. 내림차순으로 추가)
                      if (result != null && result is WritePageResult) {
                        setState(() {
                          boxList.add(BoxItem(
                            title: result.title,
                            ingredient: result.ingredient,
                            content: result.content,
                            imagePath: result.imagePath,
                            postDate: DateTime.now(),
                            id: 1, //좋아요 기능 제한 작업
                          ));
                          boxList.sort((a,b) => b.postDate.compareTo(a.postDate));
                          // 글 작성 시에 새로운 박스가 추가될 때마다 리스트를 역순을 바로 반영.
                        });
                        saveBoxList(); //작업 후 데이터 저장
                      }
                    },
                    child: Image.asset(
                      'assets/recipe_button.png', //레시피 작성 버튼(이미지)
                      width: 60.0,
                      height: 60.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

// 게시물 페이지(상세 페이지)
class DetailPage extends StatefulWidget {
  final BoxItem boxItem; // 박스 객체
  final Function(BoxItem) onDelete; // 박스 삭제
  final Function(BoxItem editedBox, int index) onEdit; // 박스 수정
  final int boxIndex; // 박스 개수
  final List<BoxItem> boxList; // 박스 리스트
  final List<CommentPage> commentPages; // 댓글 페이지를 저장하는 리스트

  DetailPage({
    required this.boxItem,
    required this.onDelete,
    required this.onEdit,
    required this.boxIndex,
    required this.boxList,
    required this.commentPages
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController titleController;
  late TextEditingController ingredientController;
  late TextEditingController contentController;
  bool isEditing = false;
  bool isLiked = false;

  /*
  TextEditingController은 텍스트 입력 위젯과
  상호 작용하여 텍스트를 읽거나 수정하는 데 사용되는 컨트롤러임.
  이 컨트롤러는 보통 TextField나 TextFormField와 함께 사용
  */

  // 위젯의 초기 상태를 설정함. 위젯이 처음으로 생성될 때 호출됨.
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.boxItem.title);
    ingredientController = TextEditingController(text: widget.boxItem.ingredient);
    contentController = TextEditingController(text: widget.boxItem.content);
  }

  // 컨트롤러가 사용되지 않을 때 메모리 누수를 방지하고 자원을 해제함. 메모리 최적화.
  @override
  void dispose() {
    titleController.dispose();
    ingredientController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void editedBox(int index) {
    widget.onEdit(BoxItem(
      title: titleController.text,
      ingredient: ingredientController.text,
      content: contentController.text,
      imagePath: widget.boxItem.imagePath,
      postDate: widget.boxItem.postDate,
      id: 1,
    ), index);
  }

  @override
  Widget build(BuildContext context) {
    final postDateTime = widget.boxItem.postDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '게시물 수정' : '게시물'),
        actions: [
          IconButton( //수정, 수정완료 버튼
            onPressed: () async {
              if (isEditing) {
                setState(() {
                  editedBox(widget.boxIndex);
                  toggleEditing();
                });
              } else {
                toggleEditing();
              }
            },
            icon: Icon(isEditing ? Icons.check : Icons.edit),
          ),
          IconButton( // 삭제 버트
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("글 삭제"),
                    content: Text("작성한 글을 삭제하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDelete(widget.boxItem);
                          Navigator.of(context).pop();
                        },
                        child: Text("삭제"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),

      // 게시물 수정 페이지 화면 구성
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async { // 이미지 선택
                        final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            widget.boxItem.imagePath = pickedImage.path;
                          });
                        }
                      },
                      child: Container( // 이미지 로드할 네모박스
                        width: 100,
                        height: 100,
                        color: Color(0xFFD9D9D9),
                        margin: EdgeInsets.only(left: 0, bottom: 8),
                        child: Icon(
                          Icons.add,
                          color: Color(0xff4ECB71),
                          size: 40,
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(width: 10),
                    if (widget.boxItem.imagePath != null) // 로드된 이미지
                      Image.file(
                        File(widget.boxItem.imagePath!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            Text('제목'),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '글 제목',
              ),
              onChanged: (value) {
                widget.boxItem.title = value;
              },
            ),
            SizedBox(height: 8.0),
            Text('레시피 재료'),
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                hintText: '레시피 재료',
              ),
            ),
            SizedBox(height: 8.0),
            Text('작성 내용'),
            SizedBox(height: 8.0),
            Container(
              width: 240,
              height: 300,
              child: TextField(
                maxLines: null, //글자수 제한
                expands: true,
                keyboardType: TextInputType.multiline,
                controller: contentController,
                decoration: InputDecoration(filled: true, hintText: '작성할 내용을 입력하세요.'),
              ),
            ),
          ],
        )
            : Column( // 게시물 페이지 화면 구성
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox( // 이미지 배치
                width: 300,
                height: 300,
                child: widget.boxItem.imagePath != null
                    ? Image.file(
                  File(widget.boxItem.imagePath!),
                  fit: BoxFit.cover,
                )
                    : SizedBox(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( //작성자 배치
                  children: [
                    Image.asset(
                      'assets/profile_image.png',
                      width: 30.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '작성자',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
                Text( //작성일자 배치
                  '${displayDateTime(postDateTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 13),
            Text(
              widget.boxItem.title ?? 'Title', // 글 제목
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: 3),
            Text(
              '연령대',
              style: TextStyle(fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 6),
            Text('레시피 재료'),
            Text(
              widget.boxItem.ingredient ?? 'ingredient',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 7),
            Divider(),
            SizedBox(height: 8),
            Text(
              widget.boxItem.content ?? 'Content', // 글 작성 내용
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isEditing
          ? Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 43,
              height: 43,
              child: IconButton( // 좋아요 버튼 클릭/해제 시 동작
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  // 로컬 데이터 저장 및 불러오기
                  final key = 'liked_${widget.boxItem.id}';
                  // 좋아요 여부를 저장하기 위한 키 생성
                  final alreadyLiked = prefs.getBool(key) ?? false;
                  //이미 좋아요를 눌렀는지 확인. 기본값은 false로 설정

                  // 좋아요를 누르지 않은 경우
                  if (!alreadyLiked) {
                    setState(() {
                      // 상태를 갱신하여 좋아요 상태로 변경
                      isLiked = true;
                      // 해당 상자 항목의 좋아요 수를 증가시킴
                      widget.boxItem.likeCount++;
                    });
                    // 로컬에 좋아요 상태를 저장
                    prefs.setBool(key, true);
                  } else { // 좋아요를 눌렀을 경우
                    setState(() {
                      // 상태를 갱신하여 좋아요를 해제
                      isLiked = false;
                      // 해당 상자 항목의 좋아요 수를 감소시킴
                      widget.boxItem.likeCount--;
                    });
                    // 로컬에서 해당 키를 제거하여 좋아요 상태 해제
                    prefs.remove(key);
                  }
                },
                icon: Icon(Icons.favorite_border),
                iconSize: 35,
                color: isLiked ? Colors.red : Color(0xff4ECB71),
                padding: EdgeInsets.zero,
              ),
            ),
            Text('좋아요수: ${widget.boxItem.likeCount}'), //즇아요 수 출력

            SizedBox(width: 25),
            SizedBox(
              width: 43.0,
              height: 43.0,
              child: IconButton( // 댓글 버튼
                onPressed: () {
                  // 새로운 댓글 페이지 생성
                  final newCommentPage = CommentPage(boxItem: widget.boxItem, commentPageId: widget.boxIndex);
                  // 리스트에 추가
                  widget.commentPages.add(newCommentPage);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => newCommentPage, //새로운 댓글 페이지로 이동
                    ),
                  );
                },
                icon: Icon(Icons.comment),
                iconSize: 30,
                color: Color(0xff4ECB71),
                padding: EdgeInsets.only(top: 2),
              ),
            ),
            SizedBox(width: 3),
            Text('댓글수'),
          ],
        ),
      )
          : null,
      floatingActionButton: isEditing
          ? FloatingActionButton(
        onPressed: () {
          toggleEditing();
        },
        child: Icon(Icons.close),
      )
          : null,
    );
  }
}

// 사용자가 입력한 정보를 저장하기 위한 클래스
class WritePageResult {
  late final String title; //글 제목
  late final String ingredient; //레시피 재료
  late final String content; //작성할 내용
  late final String? imagePath; //이미지 로드
  final DateTime postDate; // 추가된 postDate 필드

  WritePageResult({
    required this.title,
    required this.ingredient,
    required this.content,
    this.imagePath,
    required this.postDate});
}

// 글 작성 페이지
class WritePage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  File? selectedImage; // 이미지를 저장할 변수 선언
  String _selectedCategory = ''; //선택한 카테고리(학생/성인)

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글 작성하기'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column( // 글 작성하기 이미지
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      // 이미지 선택 시 선택한 이미지를 저장하고 UI를 업데이트하여 이미지를 보여줌
                      setState(() {
                        selectedImage = File(pickedImage.path);
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100, // 네모난 박스의 높이
                    color: Color(0xFFD9D9D9), // 박스의 색상
                    margin: EdgeInsets.only(left:0, bottom: 0, right: 0), // 박스와 제목 사이의 간격
                    child: Icon(
                      Icons.add,
                      color: Color(0xff4ECB71),
                      size: 40,
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(width: 10),
                // 선택한 이미지가 있을 경우 보여줌
                if (selectedImage != null)
                  Image.file(
                    selectedImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.0),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: '글 제목',
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  "카테고리 설정",
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),

                SizedBox(height: 10,),
                //카테고리 필터 메뉴 넣기
                Row(
                  children: [
                    OutlinedButton( // 학생, 성인 버튼 동작
                      onPressed: () {
                        setState(() {
                          if (_selectedCategory == '학생') {
                            _selectedCategory = ''; // 선택 취소
                          } else {
                            _selectedCategory = '학생'; // '학생' 선택
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 1.0,
                          color: _selectedCategory == '학생' ? Color(0xff4ECB71) : Colors.grey,
                        ),
                        backgroundColor: _selectedCategory == '학생' ? Color(0xff4ECB71) : Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                      ),
                      child: Text(
                        '학생',
                        style: TextStyle(
                          color: _selectedCategory == '학생' ? Colors.white : Color(0xff4ECB71), // 글자색 변경
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedCategory == '성인') {
                            _selectedCategory = ''; // 선택 취소
                          } else {
                            _selectedCategory = '성인'; // '성인' 선택
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 1.0,
                          color: _selectedCategory == '성인' ? Color(0xff4ECB71) : Colors.grey,
                        ),
                        backgroundColor: _selectedCategory == '성인' ? Color(0xff4ECB71) : Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                      ),
                      child: Text(
                        '성인',
                        style: TextStyle(
                          color: _selectedCategory == '성인' ? Colors.white : Color(0xff4ECB71), // 글자색 변경
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20,),
                TextField(
                  controller: ingredientController,
                  decoration: InputDecoration(
                    hintText: '레시피 재료',
                  ),
                ),

                SizedBox(height: 30,),
                Container(
                  width: 240, // TextField width
                  height: 220, // TextField height
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    controller: contentController,
                    decoration: InputDecoration(filled: true, hintText: '작성할 내용을 입력하세요.'),
                  ),
                ),

                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // 작성 완료 버튼이 눌렸을 때만 글이 작성되도록 수정
                    if (selectedImage == null) {
                      // 이미지를 선택하지 않았을 때는 사용자에게 알림
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                            Text(
                              '업로드 실패',
                              style: TextStyle(
                                fontSize: 20, //폰트 크기 조절
                              ),
                            ),
                            content: Text('이미지를 선택해주세요.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // 이미지를 선택한 경우 작성 완료함
                      final postDate = DateTime.now();
                      Navigator.pop(
                        context,
                        WritePageResult(
                          title: titleController.text,
                          ingredient: ingredientController.text,
                          content: contentController.text,
                          imagePath: selectedImage?.path, // 선택한 이미지의 경로를 전달함
                          postDate: postDate,
                        ),
                      );
                    }
                  },
                  child: Text('작성 완료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//필터 페이지
class FilterPage extends StatefulWidget{
  @override
  _FilterPageState createState() => _FilterPageState();
}
class _FilterPageState extends State<FilterPage> {
  String _selectedSort = '좋아요순'; // 초기값을 '좋아요순'으로 설정
  String _selectedCategory = ''; // 선택된 카테고리 (학생/성인)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('필터'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "정렬",
                    style: TextStyle(fontSize: 23),
                  ),
                  SizedBox(height: 10),
                  RadioListTile(
                    title: Text('좋아요순'),
                    value: '좋아요순',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('최신순'),
                    value: '최신순',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                  SizedBox(height: 26),
                  Text(
                    "연령대",
                    style: TextStyle(fontSize: 23),
                  ),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      OutlinedButton( //학생, 성인 버튼 동작
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '학생') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '학생'; // '학생' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '학생' ? Color(0xff4ECB71) : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '학생' ? Color(0xff4ECB71) : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '학생',
                          style: TextStyle(
                            color: _selectedCategory == '학생' ? Colors.white : Color(0xff4ECB71), // 글자색 변경
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '성인') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '성인'; // '성인' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '성인' ? Color(0xff4ECB71) : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '성인' ? Color(0xff4ECB71) : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '성인',
                          style: TextStyle(
                            color: _selectedCategory == '성인' ? Colors.white : Color(0xff4ECB71), // 글자색 변경
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 28), // 여백 크기 조절
                  child: TextButton(
                    onPressed: () {
                      // 완료 버튼 동작
                    },
                    child: Text(
                      "완료",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(120, 70)), // 최소 크기 설정
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 28), // 여백 크기 조절
                  child: TextButton(
                    onPressed: () {
                      // 취소 버튼 동작
                    },
                    child: Text(
                      "취소",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(120, 70)), // 최소 크기 설정
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//저장하기 페이지
class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<String> folders = ['기본폴더']; // 기본폴더를 포함한 폴더 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저장된 글'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 페이지 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
                  child: Text(
                    '폴더 분류',
                    style: TextStyle(
                      fontSize: 23,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 9, 0),
                  child: IconButton(
                    onPressed: () {
                      _showAddFolderDialog(); // 폴더 추가 다이얼로그 표시
                    },
                    icon: Icon(Icons.add),
                    iconSize: 40,
                  ),
                ),
              ],
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2.0, // 박스 간의 상하 간격
                crossAxisSpacing: 2.0, // 박스 간의 좌우 간격
                childAspectRatio: 1.1,
              ),
              itemCount: folders.length,
              itemBuilder: (BuildContext context, int index) {
                return GridTile(
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        folders[index],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 폴더 추가 다이얼로그 표시
  Future<void> _showAddFolderDialog() async {
    String newFolderName = ''; // 새로운 폴더 이름

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새로운 폴더 추가'),
          content: TextField(
            onChanged: (value) {
              newFolderName = value; // 입력된 폴더 이름 저장
            },
            decoration: InputDecoration(hintText: '폴더 이름 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 새로운 폴더를 추가하고 다이얼로그 닫기
                setState(() {
                  folders.add(newFolderName);
                });
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }
}

// 레시피 검색창
class RecipeSearchPage extends StatefulWidget {
  final List<BoxItem> boxList; // 전체 박스 목록

  RecipeSearchPage({required this.boxList});

  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  List<BoxItem> boxList = []; // 레시피 박스 리스트
  List<BoxItem> filteredBoxList = []; // 필터링된 목록을 저장할 변수

  @override
  void initState() {
    super.initState();
    loadBoxList();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadBoxList(); // 페이지가 화면에 나타날 때마다 데이터 업데이트
  }

  Future<void> loadBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = prefs.getString('boxList');
    if (boxListJson != null) {
      setState(() {
        boxList = (json.decode(boxListJson) as List<dynamic>)
            .map((e) => BoxItem.fromJson(e))
            .toList();
        filteredBoxList = List.from(boxList); // 초기에는 전체 목록을 필터된 목록으로 설정
      });
    }
  }

  Future<void> saveBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = json.encode(boxList.map((e) => e.toJson()).toList());
    await prefs.setString('boxList', boxListJson);
  }

  String _searchQuery = ''; // 검색어 상태 추가

  // 검색어를 기반으로 목록을 필터링하는 메서드
  void filterBoxList(String query) {
    setState(() {
      _searchQuery = query; // 검색어 상태 업데이트
      if (query.isEmpty) {
        // 검색어가 없으면 전체 목록을 필터링된 목록으로 설정
        filteredBoxList = List.from(boxList);
      } else {
        // 검색어가 포함된 박스만 필터링하여 보여줍니다.
        filteredBoxList = boxList.where((box) =>
            box.title!.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }
  Future<void> _refreshData() async {
    // 여기서 필터링된 목록을 다시 계산하고 업데이트
    filterBoxList(_searchQuery);
    // setState를 호출하여 화면을 다시 그림
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 검색'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 검색창 추가
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        // 검색어가 변경될 때마다 필터링된 결과 업데이트
                        filterBoxList(value);
                      },
                      decoration: InputDecoration(
                        hintText: '검색어를 입력하세요',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                    ],
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2.0, // 박스 간의 상하 간격
                      crossAxisSpacing: 0.0, // 박스 간의 좌우 간격
                      childAspectRatio: 0.46,
                    ),
                    itemCount: filteredBoxList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final postDateTime = filteredBoxList[index].postDate;
                      final showDateTime = displayDateTime(postDateTime);
                      // 작성된 시간을 표시하는 함수 호출
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage( //해당 페이지에서 상세(게시물) 페이지로 이동
                                    boxItem: boxList[index],
                                    boxIndex: index,
                                    onDelete: (deletedBox) {
                                      setState(() {
                                        boxList.remove(deletedBox);
                                        saveBoxList(); // 삭제 후 상태를 저장합니다.
                                        filteredBoxList = List.from(boxList); // 수정된 boxList로 filteredBoxList 업데이트
                                      });
                                      Navigator.pop(context); // 상세 페이지 닫기
                                      _refreshData();
                                    },
                                    onEdit: (editedBox, index) { // Add index parameter
                                      setState(() {
                                        boxList[index] = editedBox;
                                        saveBoxList();
                                        filteredBoxList = List.from(boxList); // 수정된 boxList로 filteredBoxList 업데이트
                                      });
                                      Navigator.pop(context);
                                      _refreshData();
                                    }, boxList: [], commentPages: [],
                                  ),
                            ),
                          );
                          if (result != null && result is WritePageResult) {
                            setState(() {
                              boxList.add(BoxItem(
                                title: result.title,
                                ingredient: result.ingredient,
                                content: result.content,
                                imagePath: result.imagePath,
                                postDate: DateTime.now(),
                                id:1,
                              ));
                            });
                            saveBoxList();
                          }
                        },

                        child: Container(
                          margin: EdgeInsets.fromLTRB(3, 3, 3, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 10.5 / 13.0,
                                    child: filteredBoxList[index].imagePath != null
                                        ? Image.file(
                                      File(filteredBoxList[index].imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                        : Image.asset(
                                      'assets/not_food_image.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6.0,
                                    left: 8.0,
                                    child: Row(
                                      children: [
                                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Text(
                                            '연령대',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 50.0),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => StoragePage()),
                                            );
                                            // 우측 상단 아이콘 동작
                                          },
                                          icon: Icon(Icons.bookmark_border),
                                          iconSize: 29,
                                          color: Color(0xff4ECB71),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      11.0, 8.0, 16.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      //작성자(기본페이지)
                                      const SizedBox(height: 2.0),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/profile_image.png',
                                            width: 22.0,
                                          ),
                                          SizedBox(width: 3.0),
                                          Text(
                                            '작성자',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      //글 제목(기본페이지)
                                      const SizedBox(height: 9.0),
                                      Text(
                                        filteredBoxList[index].title ?? 'Title',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      //작성일자(기본페이지)
                                      const SizedBox(height: 2.0),
                                      Text(
                                        showDateTime, // 수정된 부분
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: IconButton(
                                      onPressed: () {
                                        // 좌측 하단 아이콘 동작
                                      },
                                      icon: Icon(Icons.favorite_border), //좋아요
                                      iconSize: 20,
                                      color: Color(0xff4ECB71),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 0.0, top: 1.3, left: 9),
                                    child: Image.asset(
                                      'assets/comment_image.png', //댓글
                                      fit: BoxFit.cover,
                                      width: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//작성자 A의 정보
class CommentA {
  String authorName; //작성자 이름
  String text; //댓글 내용

  CommentA({required this.authorName, required this.text});

  factory CommentA.fromJson(Map<String, dynamic> json) {
    return CommentA(
      authorName: json['authorName'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'authorName': authorName, 'text': text};
  }
}

// 댓글창 페이지
class CommentPage extends StatefulWidget {
  final BoxItem boxItem; // 박스 객체
  final int commentPageId; // 댓글 페이지 식별

  CommentPage({required this.boxItem, required this.commentPageId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<CommentA> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  // 댓글 데이터 불러오기
  void loadComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? commentStrings = prefs.getStringList('${widget.commentPageId}_comments');
    if (commentStrings != null) {
      setState(() {
        comments = commentStrings
            .map((commentString) => CommentA.fromJson(jsonDecode(commentString)))
            .toList();
      });
    }
  }

  // 댓글 데이터 저장하기
  void saveComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> commentStrings = comments.map((comment) => jsonEncode(comment.toJson())).toList();
    prefs.setStringList('${widget.commentPageId}_comments', commentStrings);
  }

  // 사용되지 않을 때 메모리 누수를 방지하고 자원을 해제함. 메모리 최적화.
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('댓글'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length, //댓글 길이(개수)
              itemBuilder: (context, index) {
                return ListTile( //댓글 리스트
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comments[index].authorName}', //댓글 작성자
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(comments[index].text), // 댓글 내용
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton( // 댓글 편집 버튼
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Edit comment
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('댓글 편집'),
                                content: TextField(
                                  controller: TextEditingController(text: comments[index].text),
                                  onChanged: (value) {
                                    setState(() {
                                      comments[index].text = value;
                                    });
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      saveComments();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('저장'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      // 댓글 삭제 버튼
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            comments.removeAt(index);
                            saveComments();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField( // 댓글 입력창
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton( // 댓글 전송 버튼
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String commentText = commentController.text.trim();
                    if (commentText.isNotEmpty) { // 입력된 텍스트가 비어있지 않은지 확인
                      setState(() { // 상태 변경 확인
                        comments.add(CommentA(authorName: '작성자', text: commentText)); // comments 리스트에 새로운 CommentA 객체 추가
                        saveComments(); // 변경된 상태 저장
                        commentController.clear(); // 댓글 입력 필드 초기화하여 다시 입력할 수 있도록 함
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 좋아요창 페이지
class favoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('좋아요창'),
      ),
      body: Center(
        child: Text('좋아요창 만들기'),
      ),
    );
  }
}
