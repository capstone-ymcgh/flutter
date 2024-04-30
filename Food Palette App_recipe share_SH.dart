import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            boxItem: boxList[index], // 해당 박스의 정보를 상세 페이지에 전달
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
                          ));
                        });
                      }
                    },

                    //박스 설정
                    child: Container(
                      //margin: EdgeInsets.all(3.0),
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
                          AspectRatio(
                            aspectRatio: 10.5 / 13.0, //사진 크기 조절
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
                          // 식단 종류 추가하기
                          // 저장하기 추가하기

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(11.0, 8.0, 16.0, 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  // +작성자 추가하기
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/profile_image.png',
                                        width: 23.0,
                                        //height: 23.0,
                                      ),
                                      SizedBox(width: 3.0), // 이미지와 텍스트 사이의 간격 조정
                                      Text(
                                        '작성자',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),

                                  // 글 제목 (기본 페이지)
                                  const SizedBox(height: 5.0),
                                  Text(
                                    boxList[index].title ?? 'Title',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // +작성일자 추가하기

                                  // +좋아요수, 댓글수 추가하기

                                  //const SizedBox(height: 10.0),



                                  /* const SizedBox(height: 3.0),
                                Text(
                                  boxList[index].ingredient ?? 'Secondary Text1',
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  boxList[index].content ?? 'Secondary Text2',
                                ), */

                                ],
                              ),
                            ),
                          ),

                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0), // 아이콘을 아래로 이동
                                child: IconButton(
                                  onPressed: () {
                                    // 좌측 하단 아이콘 동작
                                  },
                                  icon: Icon(Icons.favorite_border),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0), // 아이콘을 왼쪽으로 이동
                                child: IconButton(
                                  onPressed: () {
                                    // 우측 하단 아이콘 동작
                                  },
                                  icon: Icon(Icons.person),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
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
                  ));
                });
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

class DetailPage extends StatelessWidget {
  final BoxItem boxItem;

  DetailPage({required this.boxItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              boxItem.title ?? 'Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            Text(
              boxItem.ingredient ?? 'ingredient',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              boxItem.content ?? 'Content',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            if (boxItem.imagePath != null)
              Image.file(
                File(boxItem.imagePath!),
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}


class WritePageResult {
  final String title; //글 제목
  final String ingredient; //레시피 재료
  final String content; //작성할 내용
  final String? imagePath; //이미지 로드

  WritePageResult({required this.title,required this.ingredient, required this.content, this.imagePath});
}

class BoxItem {
  final String? title;
  final String? ingredient;
  final String? content;
  final String? imagePath;

  BoxItem({this.title, this.ingredient, this.content, this.imagePath});
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
                  Navigator.pop(context, WritePageResult(
                    title: titleController.text,
                    ingredient: ingredientController.text,
                    content: contentController.text,
                    imagePath: pickedImage.path,
                  ));
                }
              },
              child: Text('이미지 선택'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  WritePageResult(
                    title: titleController.text,
                    ingredient: ingredientController.text,
                    content: contentController.text,
                    imagePath: null,
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
