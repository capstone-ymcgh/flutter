import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart'; // intl 패키지를 가져옴

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('레시피 공유'),
        ),
        body: BoxGrid(),
      ),
    );
  }
}

class BoxGrid extends StatefulWidget {
  @override
  _BoxGridState createState() => _BoxGridState();
}

class _BoxGridState extends State<BoxGrid> {
  List<BoxItem> boxList = [];

  @override
  void initState() {
    super.initState();
    loadBoxList();
  }

  Future<void> loadBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = prefs.getString('boxList');
    if (boxListJson != null) {
      setState(() {
        boxList = (json.decode(boxListJson) as List<dynamic>)
            .map((e) => BoxItem.fromJson(e))
            .toList();
      });
    }
  }

  // 작성된 지 24시간이 지났는지 여부를 판단하는 함수
  bool isPast24Hours(DateTime postDateTime) {
    final now = DateTime.now();
    final difference = now.difference(postDateTime);
    return difference.inHours >= 24;
  }

  Future<void> saveBoxList() async {
    final prefs = await SharedPreferences.getInstance();
    final boxListJson = json.encode(boxList.map((e) => e.toJson()).toList());
    await prefs.setString('boxList', boxListJson);
  }

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2.0, // 박스 간의 상하 간격
                  crossAxisSpacing: 0.0, // 박스 간의 좌우 간격
                  childAspectRatio: 0.46,
                ),
                itemCount: boxList.length,
                itemBuilder: (BuildContext context, int index) {
                  final postDateTime = boxList[index].postDate;
                  final showDateTime = displayDateTime(postDateTime); // 작성된 시간을 표시하는 함수 호출
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            boxItem: boxList[index],
                            boxIndex: index, // Pass the box index
                            onDelete: (deletedBox) {
                              setState(() {
                                boxList.remove(deletedBox);
                                saveBoxList();
                              });
                              Navigator.pop(context); // 상세 페이지 닫기
                            },
                            onEdit: (editedBox, index) { // Add index parameter
                              setState(() {
                                boxList[index] = editedBox;
                                saveBoxList();
                              });
                              Navigator.pop(context);
                            },
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
                            postDate: DateTime.now(), // 수정
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
                                child: boxList[index].imagePath != null
                                    ? Image.file(
                                  File(boxList[index].imagePath!),
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
                                    Text(
                                      '식단 종류',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 38.0),
                                    IconButton(
                                      onPressed: () {
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
                              padding: const EdgeInsets.fromLTRB(11.0, 8.0, 16.0, 0.0),
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
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  //글 제목(기본페이지)
                                  const SizedBox(height: 9.0),
                                  Text(
                                    boxList[index].title ?? 'Title',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  //작성일자(기본페이지)
                                  const SizedBox(height: 2.0),
                                  Text(
                                    showDateTime, // 수정된 부분
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
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
                                  icon: Icon(Icons.favorite_border),
                                  iconSize: 20,
                                  color: Color(0xff4ECB71),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0, top: 1.3, left: 9),
                                child: Image.asset(
                                  'assets/comment_image.png',
                                  fit: BoxFit.cover,
                                  width: 16.0,
                                ),
                                /* child: IconButton(
                                  onPressed: () {
                                    // 우측 하단 아이콘 동작
                                  },
                                  icon: Icon(Icons.mode_comment_outlined),
                                  iconSize: 20,
                                  color: Color(0xff4ECB71),
                                  padding: EdgeInsets.zero,
                                ), */
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 28.0,
          right: 20.0,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WritePage(),
                ),
              );
              if (result != null && result is WritePageResult) {
                setState(() {
                  boxList.add(BoxItem(
                    title: result.title,
                    ingredient: result.ingredient,
                    content: result.content,
                    imagePath: result.imagePath,
                    postDate: DateTime.now(), // 수정
                  ));
                });
                saveBoxList();
              }
            },
            child: Image.asset(
              'assets/recipe_button.png',
              width: 60.0,
              height: 60.0,
            ),
          ),
        ),
      ],
    );
  }
}

class DetailPage extends StatefulWidget {
  final BoxItem boxItem;
  final Function(BoxItem) onDelete;
  // 수정된 박스와 해당 박스의 인덱스를 받아들이는 onEdit 콜백 함수의 시그니처 수정
  final Function(BoxItem editedBox, int index) onEdit; // Modify the signature
  // 수정된 내용 저장 콜백 추가
  final int boxIndex;


  DetailPage({required this.boxItem, required this.onDelete, required this.onEdit, required this.boxIndex});

  @override
  _DetailPageState createState() => _DetailPageState();
}
class _DetailPageState extends State<DetailPage> {
  late TextEditingController titleController;
  late TextEditingController ingredientController;
  late TextEditingController contentController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.boxItem.title);
    ingredientController = TextEditingController(text: widget.boxItem.ingredient);
    contentController = TextEditingController(text: widget.boxItem.content);
  }

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

  // 수정된 내용을 저장하고 콜백을 호출하여 업데이트하는 메서드 수정
  void editedBox(int index) {
    // 수정된 내용을 저장하고 콜백을 호출하여 업데이트
    widget.onEdit(BoxItem(
      title: titleController.text,
      ingredient: ingredientController.text,
      content: contentController.text,
      imagePath: widget.boxItem.imagePath, // Keep the original image path
      postDate: widget.boxItem.postDate, // Keep the original post date
    ), index); // Pass the box index
  }


  @override
  Widget build(BuildContext context) {
    // 작성된 시간을 가져옴
    final postDateTime = widget.boxItem.postDate;
    // 현재 시간을 가져옴
    final now = DateTime.now();
    // 작성된 지 24시간이 지났는지 여부를 판단
    final isPast24Hours = now
        .difference(postDateTime)
        .inHours >= 24;

    // 표시할 시간을 설정
    final displayTime = isPast24Hours
        ? postDateTime.toString().split(' ')[0]
        : postDateTime.toString().split(' ')[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
        actions: [
          IconButton(
            onPressed: () async {
              if (isEditing) {
                setState(() {
                  // Save the edited content
                  editedBox(widget.boxIndex); // 수정된 내용 저장
                  // Exit edit mode
                  toggleEditing();
                });
              } else {
                // 수정 모드로 전환
                toggleEditing();
              }
            },
            icon: Icon(isEditing ? Icons.check : Icons.edit),
          ),

          IconButton(
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
                          // "취소" 버튼을 누르면 다이얼로그를 닫습니다.
                          Navigator.of(context).pop();
                        },
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          // "삭제" 버튼을 누르면 onDelete 콜백을 호출하여 해당 박스 아이템을 삭제합니다.
                          widget.onDelete(widget.boxItem);
                          Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '글 제목',
              ),
              onChanged: (value) {
                // 제목이 변경될 때마다 해당 박스의 제목도 업데이트
                widget.boxItem.title = value;
              },
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                hintText: '레시피 재료',
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: '작성할 내용',
              ),
            ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            // 편집된 이미지 적용
                            widget.boxItem.imagePath = pickedImage.path;
                          });
                        }
                      },
                      child: Text("이미지 수정"),
                    ),
                    if (widget.boxItem.imagePath != null)
                      Image.file(
                        File(widget.boxItem.imagePath!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.boxItem.title ?? 'Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.boxItem.ingredient ?? 'ingredient',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.boxItem.content ?? 'Content',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            if (widget.boxItem.imagePath != null)
              Image.file(
                File(widget.boxItem.imagePath!),
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
      floatingActionButton: isEditing
          ? FloatingActionButton(
        onPressed: () {
          toggleEditing(); // 수정 취소
        },
        child: Icon(Icons.close),
      )
          : null,
    );
  }
}

class WritePageResult {
  late final String title; //글 제목
  late final String ingredient; //레시피 재료
  late final String content; //작성할 내용
  late final String? imagePath; //이미지 로드
  final DateTime postDate; // 추가된 postDate 필드

  WritePageResult({required this.title,required this.ingredient, required this.content, this.imagePath, required this.postDate});
}

class BoxItem {
  late String? title;
  late String? ingredient;
  late String? content;
  late String? imagePath;
  final DateTime postDate; // 추가된 postDate 필드

  BoxItem({this.title, this.ingredient, this.content, this.imagePath, required this.postDate});

  // JSON 데이터를 BoxItem 객체로 변환하는 메서드
  factory BoxItem.fromJson(Map<String, dynamic> json) {
    return BoxItem(
      title: json['title'],
      ingredient: json['ingredient'],
      content: json['content'],
      imagePath: json['imagePath'],
      postDate: DateTime.parse(json['postDate']), // JSON에서 DateTime으로 변환
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

class WritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    TextEditingController ingredientController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '글 제목',
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                hintText: '레시피 재료',
              ),
            ),

            SizedBox(height: 8.0),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: '작성할 내용',
              ),
            ),


            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  // 현재 시간을 가져옴
                  final DateTime currentTime = DateTime.now();
                  Navigator.pop(context, WritePageResult(
                    title: titleController.text,
                    ingredient: ingredientController.text,
                    content: contentController.text,
                    imagePath: pickedImage.path,
                    postDate: currentTime, // 현재 시간을 postDate로 설정
                  ));
                }
              },
              child: Text('이미지 선택'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // 이미지가 선택되지 않았을 때는 현재 시간을 postDate로 설정
                final postDate = DateTime.now();
                Navigator.pop(
                  context,
                  WritePageResult(
                    title: titleController.text,
                    ingredient: ingredientController.text,
                    content: contentController.text,
                    imagePath: null,
                    postDate: postDate, // postDate를 전달
                  ),
                );
              },
              child: Text('작성 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
