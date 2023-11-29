import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SearchBarWidget(),
      ),
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  TextEditingController _searchController = TextEditingController();
  String _searchResult = '';
  FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _onLogoClick, // 로고 이미지 클릭 이벤트 함수 지정
                child: Image.asset('../assets/logo.jpg', width: 128, height: 64),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onSubmitted: (value) {
                    _updateSearchResult(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(color: _isFocused ? Color(0xff19583E) : Color(0xff656565)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Color(0xff19583E)),
                      onPressed: () {
                        _updateSearchResult(_searchController.text);
                      },
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff19583E), width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff19583E), width: 2.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(_searchResult),
        ],
      ),
    );
  }

  void _onLogoClick() { // 로고 이미지 클릭 이벤트 처리
    print('로고 이미지 클릭!');
  }

  void _updateSearchResult(String value) { // 검색창에서 엔터를 누르거나 검색 버튼을 눌렀을 때 이벤트 처리
    setState(() {
      _searchResult = '검색 결과: $value';
    });
  }
}
