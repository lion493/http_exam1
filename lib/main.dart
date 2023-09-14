import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/scroll_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String result = 'test111';
  List? data;
  TextEditingController? _editingController;
  ScrollController? _scrollController;
  int page = 1;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
    _editingController = new TextEditingController(text: 'do');
    _scrollController = new ScrollController();

    _scrollController!.addListener(() {
      if(_scrollController!.offset >= _scrollController!.position.maxScrollExtent
          && !_scrollController!.position.outOfRange ) {
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,

          decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Container(
        child: Center(
          child: data!.length == 0
              ? Text('데이타가 없습니다.')
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            //Text(data![index]['title'].toString() ),
                            //Text(data![index]['authors'].toString() ),
                            //Text(data![index]['sale_price'].toString() ),
                            //Text(data![index]['status'].toString() ),
                            Image.network(
                              data![index]['thumbnail'],
                              height: 100 ,
                              width: 100 ,
                              fit: BoxFit.contain,
                              ),
                            Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width - 150,  //스마트폰의 화면 쿼리
                                  child: Text(data![index]['title'].toString() ),
                                ),
                                Text('저자 : ${data![index]['authors'].toString()}'),
                                Text('가격 : ${data![index]['sale_price'].toString()}'),
                                Text('판매중 :${data![index]['status'].toString()} '),
                              ],
                            ),
                          ],
                        ),
                    ),
                    );
                  },
                  itemCount: data!.length,
                  controller: _scrollController,
                )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var url = 'http://www.google.com';
          var response = await http.get(Uri.parse(url));
          print(response.body.substring(1,100));
          setState(() {
            result = response.body.substring(1,200);
          });

          page = 1;
          data!.clear();

          getJSONData();
          _incrementCounter();

        },
        tooltip: 'Increment',
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Future<String> getJSONData() async {
    var url = 'https://dapi.kakao.com/v3/search/book?'
              'target=title&page=$page&query=${_editingController!.value.text}';
    var response = await http.get(Uri.parse(url)
        ,headers: {"Authorization": "KakaoAK 5ac52b9696e478229a5508204a43f191"}
    );

    setState(() {
      var dataConvertedToJson = json.decode(response.body);
      List result = dataConvertedToJson['documents'];
      data!.addAll(result);
    });
    print('good job!! ');
    return response.body;
    //print(response.body);
    //return "Successful";
  }
}
