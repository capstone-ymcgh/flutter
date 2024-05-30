import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'main.dart';
class ProductOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Colors.orange[300] ?? Colors.orange;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너를 제거
      theme: ThemeData(
        // Define the default colors for the buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: buttonColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: buttonColor,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도매가 리스트'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(productName: '', productPrice: '',)
                ),
              );
              // 장바구니 아이콘으로 바꾸기
            },
            icon: Icon(Icons.card_travel),
            iconSize: 29,
          ),
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
  List<String> comments; // New property to store comments

  //bool isSelected;

  BoxItem({
    this.title,
    this.ingredient,
    this.content,
    this.imagePath,
    required this.postDate,
    this.likeCount = 0, //기본값은 0으로 설정
    required this.id,

    List<String>? comments, // Nullable list of comments
  }) : comments = comments ?? []; // Initialize comments list

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

class BoxListProvider extends ChangeNotifier {
  List<BoxItem> _boxList = [];

  List<BoxItem> get boxList => _boxList;

  void setBoxList(List<BoxItem> newList) {
    _boxList = newList;
    notifyListeners(); // 상태가 변경됨을 Provider에 알림
  }
}

class BoxGrid extends StatefulWidget {
  @override
  _BoxGridState createState() => _BoxGridState();
}

class _BoxGridState extends State<BoxGrid> {
  List<BoxItem> boxList = [];
  //여러 BoxItem 객체들을 담는 리스트인 boxList를 선언

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
        boxList.sort((a, b) => b.postDate.compareTo(a.postDate)); // 역순으로 정렬
      });
    }
  }
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
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilterPage()),
                              );
                              // Handle sorting action
                            },
                            icon: Icon(Icons.expand_more),
                            label: Text('카테고리'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.0, color: Colors.orange[300] ?? Colors.orange
                              ), // 테두리 색상 변경
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
                            icon: Icon(Icons.expand_more), // 아이콘 지우기
                            label: Text('채소류'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.0, color: Colors.orange[300] ?? Colors.orange), // 테두리 색상 변경
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
                            label: Text('육류'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.0, color:Colors.orange[300] ?? Colors.orange , // 테두리 색상 변경
                              ),)
                          ),
                        ],
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 3.0, // 박스 간의 상하 간격
                          crossAxisSpacing: 1.0, // 박스 간의 좌우 간격
                          childAspectRatio: 0.59,
                        ),
                        itemCount: boxList.length,
                        itemBuilder: (BuildContext context, int index) {
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
                                      _refreshData();
                                    },
                                    onEdit: (editedBox, index) { // Add index parameter
                                      setState(() {
                                        boxList[index] = editedBox;
                                        saveBoxList();
                                      });
                                      Navigator.pop(context);
                                      _refreshData();
                                    }, boxList: [],
                                  ),
                                ),
                              );
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
                            // 기본 페이지
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
                                        aspectRatio: 9.1 / 8.5,
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
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(10.5, 0, 0, 148),
                                            child: Text(
                                              '종류',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 50.0),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(69.5, 137, 0, 0),
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => CartPage(
                                                    // 상품 정보를 전달
                                                    productName: boxList[index].ingredient ?? '',
                                                    productPrice: boxList[index].title ?? '',
                                                  )
                                                  ),
                                                );
                                                // 장바구니 아이콘으로 바꾸기
                                              },
                                              icon: Icon(Icons.card_travel),
                                              iconSize: 29,
                                              color: Colors.orange[300],
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
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
                                              Padding(
                                                padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Image.asset(
                                                  'assets/profile_image_yellow.png',
                                                  width: 22.0,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                                child:  Text(
                                                  '사업자명',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // 가격 표시
                                          const SizedBox(height: 5.0),
                                          Padding(
                                            padding:EdgeInsets.fromLTRB(2, 0, 0, 0),
                                            child:Text(
                                              '${boxList[index].title ?? 'Title'} 원',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          //글 제목(기본페이지)
                                          const SizedBox(height: 0.0),

                                          Padding(
                                            padding:EdgeInsets.fromLTRB(1, 0, 0, 0),
                                            child:Text(
                                              '${boxList[index].ingredient ?? 'ingredient'}',
                                              style: TextStyle(

                                                  fontSize: 18),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                        child: Container(
                                          width: 199, // 버튼의 가로 크기
                                          height: 50, // 버튼의 세로 크기
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => OrderPage(cartItems: [],)),
                                              );
                                              // 주문하기 버튼이 눌렸을 때 수행할 작업 추가
                                            },
                                            child: Text(
                                              '주문하기',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
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
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(23.0),
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
                              postDate: DateTime.now(),
                              id: 1,
                            ));
                            boxList.sort((a,b) => b.postDate.compareTo(a.postDate));
                            // 글 작성 시에 새로운 박스가 추가될 때마다 리스트를 역순을 바로 반영.
                          });
                          saveBoxList();
                        }
                      },
                      child: Image.asset(
                        'assets/recipe_button_yellow.png',
                        width: 60.0,
                        height: 60.0,
                      ),
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

//게시물 페이지 바꾸기
class DetailPage extends StatefulWidget {
  final BoxItem boxItem;
  final Function(BoxItem) onDelete;
  final Function(BoxItem editedBox, int index) onEdit;
  final int boxIndex;
  final List<BoxItem> boxList;

  DetailPage({required this.boxItem, required this.onDelete, required this.onEdit, required this.boxIndex, required this.boxList});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController titleController;
  late TextEditingController ingredientController;
  late TextEditingController contentController;
  bool isEditing = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.boxItem.title);
    ingredientController =
        TextEditingController(text: widget.boxItem.ingredient);
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
          IconButton(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        onTap: () async {
                          final pickedImage = await ImagePicker().getImage(
                              source: ImageSource.gallery);
                          if (pickedImage != null) {
                            setState(() {
                              widget.boxItem.imagePath = pickedImage.path;
                            });
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Color(0xFFD9D9D9),
                          margin: EdgeInsets.only(left: 0, bottom: 8),
                          child: Icon(
                            Icons.add,
                            color: Colors.orange[300],
                            size: 40,
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(width: 10),
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
              Text('가격'),
              TextField(
                controller: titleController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  hintText: '가격을 입력하세요',
                ),
                onChanged: (value) {
                  widget.boxItem.title = value;
                },
              ),
              SizedBox(height: 8.0),
              Text('상품 이름'),
              TextField(
                controller: ingredientController,
                decoration: InputDecoration(
                  hintText: '상품 이름을 입력하세요',
                ),
              ),
              SizedBox(height: 8.0),
              Text('상품 설명'),
              SizedBox(height: 8.0),
              Container(
                width: 240,
                height: 300,
                child: TextField(
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  controller: contentController,
                  decoration: InputDecoration(
                      filled: true, hintText: '상품 설명을 입력하세요.'),
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
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
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/profile_image_yellow.png',
                        width: 28.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '사업자명',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              Text(
                '${widget.boxItem.title ?? 'Title'} 원',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(height: 3),
              Text(
                widget.boxItem.ingredient ?? 'ingredient',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 4),
              Text(
                '종류',
                style: TextStyle(fontSize: 15.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              Divider(),
              Text('상품 설명'),
              SizedBox(height: 8),
              Text(
                widget.boxItem.content ?? 'Content',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isEditing
          ? Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Container(
                width: 300, // 버튼의 가로 크기
                height: 50, // 버튼의 세로 크기
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderPage(cartItems: [],)),
                    );
                    // 주문하기 버튼이 눌렸을 때 수행할 작업 추가
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200], // 버튼의 배경색
                  ),
                  child: Text(
                    '주문하기',
                    style: TextStyle(
                      fontSize: 20, // 버튼 내 텍스트의 폰트 크기
                      //color: Colors.white, // 버튼 내 텍스트의 색상
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15), // 아이콘 버튼과 주문하기 버튼 사이 간격 조정
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage(
                      // 상품 정보를 전달합니다.
                      productName: widget.boxItem.ingredient ?? '',
                      productPrice: widget.boxItem.title ?? '',
                    ),
                    ),
                  );
                  // 장바구니 아이콘으로 바꾸기
                },
                icon: Icon(Icons.card_travel),
                iconSize: 29,
                color: Colors.orange[300],
                padding: EdgeInsets.zero,
              ),
            ),
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

class WritePageResult {
  late final String title; //글 제목
  late final String ingredient; //레시피 재료
  late final String content; //작성할 내용
  late final String? imagePath; //이미지 로드
  final DateTime postDate; // 추가된 postDate 필드

  WritePageResult({required this.title,required this.ingredient, required this.content, this.imagePath, required this.postDate});
}

//글작성페이지 바꾸기
class WritePage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  File? selectedImage; // 이미지를 저장할 변수 선언
  String _selectedCategory = '';

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품정보 작성'),
      ),

      body: SingleChildScrollView(
        child: Padding(
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
                        color: Colors.orange[300],
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

              // 글 작성하기 내용
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.0),
                  TextField(
                    controller: titleController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: InputDecoration(
                      hintText: '가격을 입력하세요',
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
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '채소류') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '채소류'; // '채소류' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '채소류' ?Colors.orange[300] ?? Colors.orange : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '채소류' ? Colors.orange[300] : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '채소류',
                          style: TextStyle(
                            color: _selectedCategory == '채소류' ? Colors.white : Colors.orange[300] // 글자색 변경
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '육류') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '육류'; // '성인' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '육류' ? Colors.orange[300] ?? Colors.orange : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '육류' ? Colors.orange[300] : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '육류',
                          style: TextStyle(
                            color: _selectedCategory == '육류' ? Colors.white : Colors.orange[300], // 글자색 변경
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20,),
                  TextField(
                    controller: ingredientController,
                    decoration: InputDecoration(
                      hintText: '상품 이름을 입력하세요',
                    ),
                  ),

                  SizedBox(height: 30,),
                  Container(
                    width: 240,
                    height: 220,
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      controller: contentController,
                      decoration: InputDecoration(filled: true, hintText: '상품 설명을 입력하세요.'),
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
                        // 이미지를 선택한 경우 작성을 완료함
                        final postDate = DateTime.now();
                        Navigator.pop(
                          context,
                          WritePageResult(
                            title: titleController.text,
                            ingredient: ingredientController.text,
                            content: contentController.text,
                            imagePath: selectedImage?.path, // 선택한 이미지의 경로를 전달
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
      ),
    );
  }
}

//필터 페이지 바꾸기
class FilterPage extends StatefulWidget{
  @override
  _FilterPageState createState() => _FilterPageState();
}
class _FilterPageState extends State<FilterPage> {
  String _selectedSort = '가격 낮은 순'; // 초기값을 '가격낮은순'으로 설정
  String _selectedCategory = ''; // 선택된 카테고리(채소류/육류)

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
                    title: Text('가격 낮은 순'),
                    value: '가격 낮은 순',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('가격 높은 순'),
                    value: '가격 높은 순',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                  SizedBox(height: 26),
                  Text(
                    "카테고리",
                    style: TextStyle(fontSize: 23),
                  ),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '채소류') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '채소류'; // '채소류' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '채소류' ? Colors.orange[300] ?? Colors.orange : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '채소류' ? Colors.orange[300] : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '채소류',
                          style: TextStyle(
                            color: _selectedCategory == '채소류' ? Colors.white :Colors.orange[300], // 글자색 변경
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedCategory == '육류') {
                              _selectedCategory = ''; // 선택 취소
                            } else {
                              _selectedCategory = '육류'; // '성인' 선택
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: _selectedCategory == '육류' ? Colors.orange[300] ?? Colors.orange : Colors.grey,
                          ),
                          backgroundColor: _selectedCategory == '육류' ? Colors.orange[300] : Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백 조절
                        ),
                        child: Text(
                          '육류',
                          style: TextStyle(
                            color: _selectedCategory == '육류' ? Colors.white :Colors.orange[300], // 글자색 변경
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

// 도매 페이지 검색창으로 바꾸기
class RecipeSearchPage extends StatefulWidget {
  final List<BoxItem> boxList; // 전체 박스 목록

  RecipeSearchPage({required this.boxList});

  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  List<BoxItem> boxList = [];
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
            box.ingredient!.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }
  Future<void> _refreshData() async {
    // 여기서 필터링된 목록을 다시 계산하고 업데이트
    filterBoxList(_searchQuery);
    // setState를 호출하여 화면을 다시 그리도록 함
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 검색'),
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
                      crossAxisCount: 2,
                      mainAxisSpacing: 3.0, // 박스 간의 상하 간격
                      crossAxisSpacing: 1.0, // 박스 간의 좌우 간격
                      childAspectRatio: 0.59,
                    ),
                    itemCount: filteredBoxList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                boxItem:filteredBoxList[index],
                                boxIndex: index,
                                onDelete: (deletedBox) {
                                  setState(() {
                                    boxList.remove(deletedBox);
                                    saveBoxList(); // 삭제 후 상태를 저장
                                    filteredBoxList = List.from(boxList); // 수정된 boxList로 filteredBoxList 업데이트
                                  });
                                  Navigator.pop(context); // 상세 페이지 닫기
                                  _refreshData();
                                },
                                onEdit: (editedBox, index) {
                                  setState(() {
                                    boxList[index] = editedBox;
                                    saveBoxList();
                                    filteredBoxList = List.from(boxList); // 수정된 boxList로 filteredBoxList 업데이트
                                  });
                                  Navigator.pop(context);
                                  _refreshData();
                                }, boxList: [],
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
                                    aspectRatio: 9.1 / 8.5,
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
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.5, 0, 0, 148),
                                        child: Text(
                                          '종류',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 50.0),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(69.5, 137, 0, 0),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => CartPage(
                                                // 상품 정보를 전달합니다.
                                                productName: boxList[index].ingredient ?? '',
                                                productPrice: boxList[index].title ?? '',
                                              ),
                                              ),
                                            );
                                            // 장바구니 아이콘으로 바꾸기
                                          },
                                          icon: Icon(Icons.card_travel),
                                          iconSize: 29,
                                          color: Colors.orange[300],
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
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
                                          Padding(
                                            padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Image.asset(
                                              'assets/profile_image_yellow.png',
                                              width: 22.0,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                            child:  Text(
                                              '사업자명',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 가격 표시
                                      const SizedBox(height: 5.0),
                                      Padding(
                                        padding:EdgeInsets.fromLTRB(2, 0, 0, 0),
                                        child:Text(
                                          '${filteredBoxList[index].title ?? 'Title'} 원',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      //글 제목(기본페이지)
                                      const SizedBox(height: 0.0),

                                      Padding(
                                        padding:EdgeInsets.fromLTRB(2, 0, 0, 0),
                                        child:Text(
                                          '${filteredBoxList[index].ingredient ?? 'ingredient'}',
                                          style: TextStyle(
                                              fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: Container(
                                      width: 199, // 버튼의 가로 크기
                                      height: 50, // 버튼의 세로 크기
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => OrderPage(cartItems: [],)),
                                          );
                                          // 주문하기 버튼이 눌렸을 때 수행할 작업 추가
                                        },
                                        child: Text(
                                          '주문하기',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
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

//주문하기 페이지
class OrderPage extends StatefulWidget {
  final List<CartItem> cartItems; // 선택한 목록을 전달받음

  OrderPage({required this.cartItems});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? shippingAddress;
  String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '배송지',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(shippingAddress ?? '배송지를 선택해주세요'),
                ),
                TextButton(
                  onPressed: () {
                    // 배송지 선택 페이지를 열고 주소를 가져와 shippingAddress에 저장
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShippingAddressPage(
                          onAddressSelected: (name, phoneNumber, address) {
                            setState(() {
                              shippingAddress = '$name\n$phoneNumber\n$address';
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Text('배송지 선택'),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              '결제수단',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              children: [
                RadioListTile(
                  title: Text('신용/체크카드'),
                  value: '신용/체크카드',
                  groupValue: paymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      paymentMethod = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('계좌이체/무통장입금'),
                  value: '계좌이체/무통장입금',
                  groupValue: paymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      paymentMethod = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('휴대폰결제'),
                  value: '휴대폰결제',
                  groupValue: paymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      paymentMethod = value;
                    });
                  },
                ),
              ],
            ),
            Spacer(),

            // 결제하기 버튼(OrderPage)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('결제 확인'),
                        content: Text('정말로 결제하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // 취소 버튼을 누른 경우, false 반환
                            },
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // 확인 버튼을 누른 경우, true 반환
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  ).then((confirmed) {
                    if (confirmed != null && confirmed) {
                      // 확인 버튼을 누른 경우, 결제가 완료되었음을 알림
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('결제 완료'),
                            content: Text('결제가 완료되었습니다.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(widget.cartItems.where((item) => item.isSelected).toList());
                                  //Navigator.of(context).pop(); // 결제 완료 다이얼로그 닫기
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(initialIndex: 3), // 초기 인덱스를 2로 설정
                                    ),
                                        (route) => false,
                                  );
                                  //Navigator.of(context).pop(true); // 결제 완료를 알리면서 주문 페이지를 닫음
                                  // 주문 페이지(OrderPage)에서 결제가 완료된 항목들을 반환합니다.
                                  //Navigator.of(context).pop(widget.cartItems.where((item) => item.isSelected).toList());
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      ).then((completedItems) {
                        if (completedItems != null && completedItems.isNotEmpty)
                      {Navigator.of(context).pop(completedItems); }
                      }); // 결제가 완료된 항목들을 반환
                    }
                  });
                },
                child: Text('결제하기'), //OrderPage
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//장바구니 페이지 만들기
class CartItem {
  final int id; // 고유 id 필드 추가
  final String name;
  final int price;
  bool isSelected;

  CartItem({required this.id, required this.name, required this.price, this.isSelected = false});

  // JSON 변환을 위한 메서드 추가
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      isSelected: json['isSelected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'isSelected': isSelected,
    };
  }
}


class CartPage extends StatefulWidget {
  final String productName;
  final String productPrice;

  CartPage({required this.productName, required this.productPrice});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  List<BoxItem> boxList = [];
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _addToCart(widget.productName, widget.productPrice); // 새로운 데이터 추가


  }


  // 장바구니 항목을 로드합니다.
  void _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartItemsJson = prefs.getString('cartItems');
    if (cartItemsJson != null) {
      List<dynamic> decodedItems = json.decode(cartItemsJson);
      List<CartItem> loadedItems = decodedItems
          .map((item) => CartItem.fromJson(item))
          .toList();
      setState(() {
        cartItems.addAll(loadedItems);
      });
    }
  }

  void _saveCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> encodedItems = cartItems
        .map((item) => item.toJson())
        .toList();
    String cartItemsJson = json.encode(encodedItems);
    prefs.setString('cartItems', cartItemsJson);
  }

  void _addToCart(String? productName, String? productPrice) {
    if (productName != null && productPrice != null) {
      int? price = int.tryParse(productPrice.replaceAll(',', ''));
      if (price != null) {
        setState(() {
          int id = DateTime
              .now()
              .millisecondsSinceEpoch; // 고유 id 생성
          cartItems.add(CartItem(id: id, name: productName, price: price));
          _saveCartItems();
        });
      } else {
        print('Failed to parse price');
      }
    } else {
      print('Product name or price is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = 0;

    //상품 가격 합계
    cartItems.forEach((item) {
      if (item.isSelected) {
        total += item.price;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: cartItems[index].isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        cartItems[index].isSelected = value ?? false;
                      });
                    },
                  ),
                  title: Text(cartItems[index].name),
                  subtitle: Text(
                      '${NumberFormat.currency(locale: 'ko_KR', symbol: '')
                          .format(cartItems[index].price)} 원'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        cartItems.removeAt(index);
                        _saveCartItems();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isAllSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          isAllSelected = value ?? false;
                          cartItems.forEach((item) {
                            item.isSelected = isAllSelected;
                          });
                        });
                      },
                    ),
                    Text('전체 선택'),
                  ],
                ),
                Text(
                  '합계: ${NumberFormat.currency(locale: 'ko_KR', symbol: '')
                      .format(total)} 원',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderPage(cartItems: cartItems.where((item) =>
                          item.isSelected)
                              .toList()), // 선택한 목록을 주문하기 페이지로 전달
                    ),
                  ).then((completedItems) {
                    if (completedItems != null && completedItems.isNotEmpty) {
                      // 결제가 완료된 항목들을 장바구니에서 제거
                      setState(() {
                        cartItems.removeWhere((item) =>
                            completedItems.any((completedItem) => completedItem
                                .id == item.id));
                        _saveCartItems(); // 변경된 장바구니 목록을 저장
                      });
                    }
                  });
                },
                child: Text('결제하기'), //CartPage
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//배송지 선택 페이지
class ShippingAddressPage extends StatefulWidget {
  final Function(String, String, String) onAddressSelected;

  ShippingAddressPage({required this.onAddressSelected});

  @override
  _ShippingAddressPageState createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('배송지 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이름',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요',
              ),
            ),
            SizedBox(height: 20),
            Text(
              '전화번호',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '전화번호를 입력해주세요',
              ),
              onChanged: (String value) {
                if (value.length == 3 || value.length == 8) {
                  // 번호 입력에 따라 '-'를 자동으로 추가
                  _phoneNumberController.text = '$value-';
                  _phoneNumberController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _phoneNumberController.text.length),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              '주소',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: '주소를 입력해주세요',
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 입력된 정보를 가져와서 부모 위젯으로 전달하고 페이지 닫기
                  String name = _nameController.text;
                  String phoneNumber = _phoneNumberController.text;
                  String address = _addressController.text;
                  widget.onAddressSelected(name, phoneNumber, address);
                  Navigator.pop(context);
                },
                child: Text('주소 선택 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 입력시 쉼표 자동 추가
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double value = double.parse(newValue.text.replaceAll(',', ''));
    final String newText = NumberFormat('#,###').format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}