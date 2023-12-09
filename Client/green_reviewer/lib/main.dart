import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (create) => GlobalStore())
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      title: '그린리버',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            WholeScreen(),
          ]
        )
      ),
    );
  }
}

class WholeScreen extends StatefulWidget {
  @override
  _WholeScreenState createState() => _WholeScreenState();
}

class _WholeScreenState extends State<WholeScreen> {
  ScrollController _scrollController = ScrollController();
  double scrollPosition = 0.0;
  bool isDone = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<int?> checklists = [0, 0, 0, 0];

  Future<void> fetchDataAndSubmit() async {
    final url = 'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/review/write';
    final data = {
      'id': context.read<GlobalStore>().detail_id,
      'name': nameController.text,
      'password': passwordController.text,
      'checklists': checklists,
      'content': contentController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      // Handle the response
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
    } catch (error) {
      // print('Error: $error');
    }
  }

  Future<bool> deleteRequest() async {
    final url = 'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/review/delete?product_id=${context.read<GlobalStore>().detail_id}&review_id=${context.read<GlobalStore>().review_id}&password=${passwordController.text}';
    // print(url);
    try {
      final response = await http.delete(
        Uri.parse(url),
      );
      // print(response.body);
      if (response.body == 'sucess')
        return true;
      return false;
      // Handle the response
    } catch (error) {
      // print('Error: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (context.read<GlobalStore>().isDialogOpen && scrollPosition < 100) {
            Provider.of<GlobalStore>(context, listen: false)._scrollValue = scrollPosition;
            _scrollController.jumpTo(scrollPosition);
          } else {
            scrollPosition = notification.metrics.pixels;
          }
        }
        return true;
      },
      child: Stack(
        children: [
          Column(
            children: [
              SearchBarWidget(
                onSearchResultUpdate: () {
                  setState(() {});
                  if (!context.read<GlobalStore>().isDialogOpen) {
                    if (context.read<GlobalStore>()._pageChangeDetect == true) {
                      _scrollController.jumpTo(0.0);
                      Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = false;
                    } else {
                      _scrollController.animateTo(0, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
                    }
                    setState(() {});
                  } else {
                    _scrollController.jumpTo(scrollPosition);
                  }
                },
              ),
              Expanded(
                child: ProductList(
                  pageItemNumber: 10,
                  scrollController: _scrollController,
                  onPageUpdate: () {
                    setState(() {});
                    if (!context.read<GlobalStore>().goReview) {
                      if (!context.read<GlobalStore>().isDialogOpen) {
                        if (context.read<GlobalStore>()._pageChangeDetect == true) {
                          _scrollController.jumpTo(0.0);
                          Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = false;
                        } else {
                          _scrollController.animateTo(0, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
                        }
                      } else {
                        _scrollController.jumpTo(scrollPosition);
                      }
                      setState(() {});
                      if (context.read<GlobalStore>().isDialogOpen || context.read<GlobalStore>().reviewPageChange) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<GlobalStore>(context, listen: false)._scrollValue = _scrollController.position.maxScrollExtent;
                          _scrollController.jumpTo(scrollPosition + 5000);
                        });
                        Provider.of<GlobalStore>(context, listen: false).reviewPageChange = false;
                      }
                    }
                    else {
                      Provider.of<GlobalStore>(context, listen: false).goReview = false;
                      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
                    }
                  },
                ),
              ),
            ],
          ),
          if (context.read<GlobalStore>().isDialogOpen) 
            DialogContainer(
              nameController: nameController,
              passwordController: passwordController,
              checklists: checklists,
              contentController: contentController,
              scrollController: _scrollController,
              scrollPosition: scrollPosition,
              fetchDataAndSubmit: fetchDataAndSubmit,
              deleteRequest: deleteRequest,
              onPageUpdate: () {
                // ... (이후 코드 추가)
                setState(() {});
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<GlobalStore>(context, listen: false)._scrollValue = _scrollController.position.maxScrollExtent;
                  _scrollController.jumpTo(scrollPosition + 5000);
                });
              },
            ),
        ]
      ),
    );
  }    
}

class DialogContainer extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController passwordController;
  List<int?> checklists = [0, 0, 0, 0];
  final TextEditingController contentController;
  final ScrollController scrollController;
  final double scrollPosition;
  final Function fetchDataAndSubmit;
  final Function deleteRequest;

  final VoidCallback onPageUpdate; // Add this line

  DialogContainer({
    required this.nameController,
    required this.passwordController,
    required this.checklists,
    required this.contentController,
    required this.scrollController,
    required this.scrollPosition,
    required this.fetchDataAndSubmit,
    required this.deleteRequest,
    required this.onPageUpdate, // Add this line
  });

  @override
  _DialogContainerState createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogContainer> {
  String notifyPassword = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Provider.of<GlobalStore>(context, listen: false).isDialogOpen = false;
            Provider.of<GlobalStore>(context, listen: false).isDelete = false;
            Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;

            // Clear the text field controllers
            widget.nameController.clear();
            widget.passwordController.clear();
            widget.contentController.clear();
            widget.checklists[0] = 0;
            widget.checklists[1] = 0;
            widget.checklists[2] = 0;
            widget.checklists[3] = 0;

            // Call the onPageUpdate callback
            widget.onPageUpdate();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        if (!context.read<GlobalStore>().isDelete) // Write Dialog
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width > 800 ? 450 : 220,
              height: MediaQuery.of(context).size.width > 800 ? 600 : 450,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 800 ? 100.0 : 70),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 40.0 : 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('작성자', style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                            color: Color(0xff1a5545),
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width > 800 ? 20 : 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: TextField(
                                  controller: widget.nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 800 ? 25.0 : 15.0, horizontal: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xfff37cd5), width: MediaQuery.of(context).size.width > 800 ? 3.5 : 2.0),
                                    ),
                                    // Remove the labelText when focused
                                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  ),
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                                )
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width > 800 ? 10 : 5.0),
                            Expanded(
                              child: Container(
                                child: TextField(
                                  controller: widget.passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 800 ? 25.0 : 15.0, horizontal: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                      borderSide: BorderSide(color: Color(0xfff37cd5), width: MediaQuery.of(context).size.width > 800 ? 3.5 : 2.0),
                                    ),
                                    // Remove the labelText when focused
                                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  ),
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                                )
                              )
                            )
                          ]
                        )
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('그린워싱 유형', style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                            color: Color(0xff1a5545),
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width > 800 ? 20 : 10),
                        _buildCustomCheckbox('증거 불충분', 0),
                        _buildCustomCheckbox('부적절한 인증 라벨', 1),
                        _buildCustomCheckbox('애매모호한 주장', 2),
                        _buildCustomCheckbox('거짓말', 3),
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('리뷰', style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                            color: Color(0xff1a5545),
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width > 800 ? 20 : 10),
                        TextField(
                          controller: widget.contentController,
                          onSubmitted: (value) {
                            if (widget.nameController.text != "" && widget.passwordController.text != "" && widget.contentController.text != "") {
                              // Use Provider to update the state
                              widget.fetchDataAndSubmit();
                              Provider.of<GlobalStore>(context, listen: false).isDialogOpen = false;
                              Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;

                              // Clear the text field controllers
                              widget.nameController.clear();
                              widget.passwordController.clear();
                              widget.contentController.clear();
                              widget.checklists[0] = 0;
                              widget.checklists[1] = 0;
                              widget.checklists[2] = 0;
                              widget.checklists[3] = 0;

                              // Call the onPageUpdate callback
                              widget.onPageUpdate();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Content',
                            contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 800 ? 25.0 : 15.0, horizontal: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                            suffixIcon: InkWell(
                              onTap: () async {
                                if (widget.nameController.text != "" && widget.passwordController.text != "" && widget.contentController.text != "") {
                                  // Use Provider to update the state
                                  widget.fetchDataAndSubmit();
                                  Provider.of<GlobalStore>(context, listen: false).isDialogOpen = false;
                                  Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;

                                  // Clear the text field controllers
                                  widget.nameController.clear();
                                  widget.passwordController.clear();
                                  widget.contentController.clear();
                                  widget.checklists[0] = 0;
                                  widget.checklists[1] = 0;
                                  widget.checklists[2] = 0;
                                  widget.checklists[3] = 0;

                                  // Call the onPageUpdate callback
                                  widget.onPageUpdate();
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 8.0 : 4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('작성    ', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 15 : 8,
                                      color: Color(0xff19583E))
                                    )
                                  ]
                                )
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.0),
                              borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.0),
                              borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3 : 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.0),
                              borderSide: BorderSide(color: Color(0xfff37cd5), width: MediaQuery.of(context).size.width > 800 ? 3.5 : 2.0),
                            ),
                            // Remove the labelText when focused
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width > 800 ? 20.0 : 12.0),
                        )
                      ]
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (context.read<GlobalStore>().isDelete) // Delete Dialog
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width > 800 ? 450 : 250,
              height: MediaQuery.of(context).size.width > 800 ? 210 : 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 800 ? 70.0 : 50),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 40.0 : 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('비밀번호', style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                                color: Color(0xff1a5545),
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width > 800 ? 16 : 8),
                            Text(notifyPassword, style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 800 ? 15 : 7,
                                color: Colors.red,
                              )
                            ),
                          ]
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width > 800 ? 20 : 10),
                        Container(
                          child: TextField(
                            obscureText: true,
                            controller: widget.passwordController,
                            onSubmitted: (value) async {
                              if (widget.passwordController.text != "") {
                                // Use Provider to update the state
                                bool isSuccess = await widget.deleteRequest();
                                
                                // Clear the text field controllers
                                widget.passwordController.clear();

                                if (isSuccess) {
                                  Provider.of<GlobalStore>(context, listen: false).isDialogOpen = false;
                                  Provider.of<GlobalStore>(context, listen: false).isDelete = false;
                                  Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;

                                  // Call the onPageUpdate callback
                                  widget.onPageUpdate();
                                }
                                else {
                                  notifyPassword = '비밀번호가 잘못되었습니다.';
                                }
                              }
                              else {
                                notifyPassword = '';
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 800 ? 25.0 : 15.0, horizontal: MediaQuery.of(context).size.width > 800 ? 20.0 : 10.0),
                              suffixIcon: InkWell(
                                onTap: () async {
                                  if (widget.passwordController.text != "") {
                                    // Use Provider to update the state
                                    bool isSuccess = await widget.deleteRequest();
                                    
                                    // Clear the text field controllers
                                    widget.passwordController.clear();

                                    if (isSuccess) {
                                      Provider.of<GlobalStore>(context, listen: false).isDialogOpen = false;
                                      Provider.of<GlobalStore>(context, listen: false).isDelete = false;
                                      Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;

                                      // Call the onPageUpdate callback
                                      widget.onPageUpdate();
                                    }
                                    else {
                                      notifyPassword = '비밀번호가 잘못되었습니다.';
                                    }
                                  }
                                  else {
                                    notifyPassword = '';
                                  }
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 8.0 : 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('OK    ', style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width > 800 ? 15 : 8,
                                        color: Color(0xff19583E))
                                      )
                                    ]
                                  )
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3.0 : 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Color(0xff19583E), width: MediaQuery.of(context).size.width > 800 ? 3.0 : 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Color(0xfff37cd5), width: MediaQuery.of(context).size.width > 800 ? 3.5 : 2.0),
                              ),
                              // Remove the labelText when focused
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width > 800 ? 20.0 : 12.0),
                          )
                        )
                      ]
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomCheckbox(String title, int index) {
    return Row(
      children: [
        Checkbox(
          value: widget.checklists[index] == 1,
          onChanged: (value) {
            setState(() {
              widget.checklists[index] = value == true ? 1 : 0;
            });
          },
          activeColor: Color(0xfffb4e9f),
        ),
        Text(title, style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 800 ? 20 : 10,
          )
        ),
      ],
    );
  }
}



class SearchBarWidget extends StatefulWidget {
  final VoidCallback onSearchResultUpdate;
  SearchBarWidget({required this.onSearchResultUpdate});
  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> with ChangeNotifier {
  TextEditingController _searchController = TextEditingController();
  String _searchResult = '';
  FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String get searchResult => _searchResult;

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
    return Container(
      width: 2000,
      height: 65,
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width > 800 ? 32 : 24),
          GestureDetector(
            onTap: _onLogoClick,
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // Change cursor shape to indicate clickability
              child: Image.asset('assets/logo.png', width: MediaQuery.of(context).size.width > 800 ? 128 : 90, height: MediaQuery.of(context).size.width > 800 ? 64 : 45),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width > 800 ? 32 : 24),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: (value) {
                _updateSearchResult(value);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: _isFocused ? Color(0xff19583E) : Color(0xff656565),
                  fontSize: 12.0,
                ),
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
          SizedBox(width: MediaQuery.of(context).size.width > 800 ? 32 : 32),
        ],
      ),
    );
  }

  void _onLogoClick() {
    _updateSearchResult('용기');
  }

  void _updateSearchResult(String searchword) {
    _searchController.clear();
    fetchProducts(searchword).then((List<Product> fetchedProducts) {
      Provider.of<GlobalStore>(context, listen: false).products = fetchedProducts;
      Provider.of<GlobalStore>(context, listen: false).currentPage = 1;
      Provider.of<GlobalStore>(context, listen: false).reviewPage = 1;
      if (context.read<GlobalStore>()._isDetail == true) {
        Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = true;
        Provider.of<GlobalStore>(context, listen: false)._isDetail = false;
      }
      notifyListeners();
      widget.onSearchResultUpdate();
    });
  }
}

class ProductList extends StatefulWidget {
  final int pageItemNumber;
  final ScrollController scrollController;
  final VoidCallback onPageUpdate;

  ProductList({required this.pageItemNumber, required this.scrollController, required this.onPageUpdate});
  
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> with ChangeNotifier {
  int _hoveredIndex = -1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    updateProductDetails('용기');
  }

  void updateProductDetails(String searchword) async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<Product> updatedProducts = await fetchProducts(searchword);
      setState(() {
        context.read<GlobalStore>().products = updatedProducts;
      });
    } catch (e) {
      // print('제품을 가져오는 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController, // Assign ScrollController to the ListView.builder
            itemCount: context.read<GlobalStore>()._isDetail ? 1 : ((context.read<GlobalStore>().currentPage == (context.read<GlobalStore>().products.length) ~/ 8 + 1) ? (context.read<GlobalStore>().products.length % 8) + 1 : 9),
            itemBuilder: (context, index) {
              if (context.read<GlobalStore>().products.length == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 24.0),
                    Text('No Such Items'),
                    SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 24.0),
                    PageNavigation(
                      currentPage: 1,
                      totalPages: 1,
                      onPageChanged: (page) {
                      },
                    )
                  ],
                );
              }
              if (index == 8 || (context.read<GlobalStore>().currentPage == (context.read<GlobalStore>().products.length) ~/ 8 + 1 && index == context.read<GlobalStore>().products.length % 8)) {
                return PageNavigation(
                  currentPage: context.read<GlobalStore>().currentPage,
                  totalPages: (context.read<GlobalStore>().products.length) ~/ 8 + 1,
                  onPageChanged: (page) {
                    if(page != context.read<GlobalStore>().currentPage) {
                      context.read<GlobalStore>().currentPage = page;
                      setState(() {});
                      widget.onPageUpdate();
                    }
                  },
                );
              }
              return MouseRegion(
                onEnter: (_) {
                  if (context.read<GlobalStore>()._isDetail == true) {
                  
                  }
                  else {
                    setState(() {
                      Provider.of<GlobalStore>(context, listen: false)._isHover = true;
                      _hoveredIndex = index;
                    });
                  }
                },
                onExit: (_) {
                  if (context.read<GlobalStore>()._isDetail == true) {

                  }
                  else {
                    setState(() {
                      Provider.of<GlobalStore>(context, listen: false)._isHover = false;
                      _hoveredIndex = _hoveredIndex;
                    });
                  }
                },
                child: GestureDetector( 
                  onTap: () {
                    if (context.read<GlobalStore>()._isDetail == true) {

                    }
                    else {
                      _hoveredIndex = index;
                      Provider.of<GlobalStore>(context, listen: false)._isDetail = true;
                      Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = true;
                      Provider.of<GlobalStore>(context, listen: false).detailID = context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + _hoveredIndex].productID;
                      widget.onPageUpdate();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width > 800 ? 32.0 : 8.0), // Padding Box
                    child: context.read<GlobalStore>()._isDetail ? _detailScreen() : Column(
                      children: [
                        Container( 
                          // Product List View
                          width: 2000,
                          decoration: BoxDecoration(
                            border: Border(
                              top: index == 0 ? BorderSide(color: Color(0xFFDCDCDC)) : BorderSide.none,
                              bottom: BorderSide(color: Color(0xFFDCDCDC)),
                            ),
                            color: (_hoveredIndex == index && context.read<GlobalStore>()._isHover == true) ? Color(0xFFF5F5F5) : Colors.transparent,
                          ),
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 800 ? 16.0 : 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width > 800 ? 256.0 : 150,
                                        height: MediaQuery.of(context).size.width > 800 ? 256.0 : 150,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFF808080),
                                            width: 1.0,          
                                          ),
                                        ),
                                        child: Image.network(
                                          context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].thumbnail,
                                          width: 128.0,
                                          height: 128.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 800 ? 45.0 : 20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: MediaQuery.of(context).size.width > 800 ? 20.0 : 12),
                                            Text(context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].productName,
                                              style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width > 800 ? 28 : 13,
                                              )
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.width > 800 ? 24.0 : 16),
                                            Text('${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].vendor}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width > 800 ? 20 : 11,
                                                color: Colors.grey, 
                                              )
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.width > 800 ? 90 : 35),
                                            Text('리뷰 수: ${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].reviewCount}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width > 800 ? 20 : 11,
                                                color: Color(0xff469174),
                                              )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: MediaQuery.of(context).size.width > 800 ? 256 : 150,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width > 800 ? 40.0 : 20,
                                                  height: MediaQuery.of(context).size.width > 800 ? 40.0 : 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].state == 0 ? Color(0xffb4b4b4) :
                                                           context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].state == 1 ? Color(0xffc5d7b0) :
                                                           context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].state == 2 ? Color(0xfff1e370) :
                                                           context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].state == 3 ? Color(0xfffea7a7) : Color(0xffFFFFFF),
                                                  ),
                                                )
                                              ]
                                            )
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.width > 800 ? 15 : 8),
                                          SizedBox(height: MediaQuery.of(context).size.width > 800 ? 15 : 8),
                                          Text('${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].price}원',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width > 800 ? 32 : 11,
                                              color: Color(0xffa1b87e),
                                            )
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]
                          )
                        ),
                      ]
                    )
                  ),
                ),            
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String> fetchProductDetails(String productId) async {
    String url = 'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/detail?id=$productId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<String> fetchReviewContents(String productId) async {
    String url = 'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/review/content?id=$productId&page=1&size=100';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load review contents');
    }
  }

  Container _detailScreen() {
    return Container(
      child: FutureBuilder<String>(
        future: fetchProductDetails(context.read<GlobalStore>().detailID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터가 로딩 중인 경우
            return Text('Loading...');
          } else if (snapshot.hasError) {
            // 에러가 발생한 경우
            return Text('Error: ${snapshot.error}');
          } else {
            // 데이터가 성공적으로 로딩된 경우
            var detailJson = json.decode(snapshot.data!);
            var productID = detailJson['id'];
            var productName = detailJson['name'];
            var productVendor = detailJson['vendor'];
            var productPrice = translatePrice(detailJson['price']);
            var productDeliveryFee = translatePrice(detailJson['deliveryFee']);
            var productPicUrl = detailJson['picUrl'];
            var productOriginalUrl = detailJson['originalUrl'];
            var productDetailPicUrls = detailJson['detailpicUrl'];
            var productChecklists = json.decode(detailJson['checklists']);
            Provider.of<GlobalStore>(context, listen: false).checklists = [
              productChecklists[0].toDouble(),
              productChecklists[1].toDouble(),
              productChecklists[2].toDouble(),
              productChecklists[3].toDouble()
            ];
            Provider.of<GlobalStore>(context, listen: false).detail_id = productID;
            // print(context.read<GlobalStore>().checklists);
            // productReviews를 List<dynamic>으로 선언
            List<dynamic> productReviews = [];

            return FutureBuilder<String>(
              future: fetchReviewContents(context.read<GlobalStore>().detailID),
              builder: (context, reviewSnapshot) {
                if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                  // 리뷰 데이터가 로딩 중인 경우
                  return Text('Loading...');
                } else if (reviewSnapshot.hasError) {
                  // 리뷰 로딩 중에 에러가 발생한 경우
                  return Text('Error: ${reviewSnapshot.error}');
                } else if (snapshot.data == null) {
                  // 데이터가 존재하지 않는 경우
                  return Text('Data is null');
                } else {
                  // 리뷰가 성공적으로 로딩된 경우
                  if(!context.read<GlobalStore>().initReview) {
                    Provider.of<GlobalStore>(context, listen: false).reviewPage = 1;
                    Provider.of<GlobalStore>(context, listen: false).initReview = true;
                  }
                  productReviews = json.decode(json.decode(reviewSnapshot.data!));
                  // print(productReviews);

                  return Column(
                    children: [
                      // Top Container with Image
                      Container(
                        width: 1300, // You can adjust the height as needed
                        height: MediaQuery.of(context).size.width > 800 ? 600 : 300, // You can adjust the height as needed
                        child: Row(
                          children: [
                            Expanded(
                              child: Image.network(
                                detailJson['picUrl'], // Assuming 'picUrl' is the key for the image
                                width: MediaQuery.of(context).size.width > 800 ? 600 : 300,
                                height: MediaQuery.of(context).size.width > 800 ? 600 : 300,
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width > 800 ? 16 : 8), // Adjust the spacing as needed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(productName, style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 45 : 14,
                                        )
                                      ),
                                      Text(productVendor, style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 22 : 12,
                                          color: Colors.grey, 
                                        )
                                      ),
                                      Text('리뷰 수: ${productReviews.length}', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 22 : 12,
                                          color: Color(0xff469174),
                                        )
                                        ),
                                    ],
                                  ),
                                  if(MediaQuery.of(context).size.width > 800) 
                                    SizedBox(height: 16),
                                  if(MediaQuery.of(context).size.width > 800) 
                                    SizedBox(height: 16),
                                  if(MediaQuery.of(context).size.width > 800) 
                                    SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('배송비: ${productDeliveryFee}원', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 23 : 10,
                                        )
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 14 : 7),
                                      Text('${productPrice}원', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 27 : 17,
                                          color: Color(0xffa1b87e),
                                        )
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Handle Purchase button click
                                              if (await canLaunch(productOriginalUrl)) {
                                                await launch(productOriginalUrl);
                                              } else {
                                                throw 'Could not launch $productOriginalUrl';
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xffbfd0a6), // 배경색
                                              onPrimary: Color(0xffbfd0a6), // 텍스트 및 아이콘 색상
                                              side: BorderSide(color: Color(0xffbfd0a6)), // 테두리 색상 및 너비
                                              minimumSize: Size(MediaQuery.of(context).size.width > 800 ? 300 : 40, MediaQuery.of(context).size.width > 800 ? 64 : 32),
                                            ),
                                            child: Text('구매하기', style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width > 800 ? 24 : 13,
                                                color: Colors.white,
                                              )
                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width > 800 ? 32 : 5),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle Check Review button click
                                              Provider.of<GlobalStore>(context, listen: false).goReview = true;
                                              // print("-----Change-@@---${context.read<GlobalStore>().reviewPage}");
                                              setState(() {});
                                              widget.onPageUpdate();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white, // 배경색
                                              onPrimary: Colors.white, // 텍스트 및 아이콘 색상
                                              side: BorderSide(color: Color(0xffbfd0a6)), // 테두리 색상 및 너비
                                              minimumSize: Size(MediaQuery.of(context).size.width > 800 ? 300 : 40, MediaQuery.of(context).size.width > 800 ? 64 : 32),
                                            ),
                                            child: Text('리뷰확인', style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width > 800 ? 24 : 13,
                                                color: Color(0xffbfd0a6),
                                              )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 16 : 8),
                      // Detail Images
                      if (productDetailPicUrls != null)
                        for (var detailPicUrl in productDetailPicUrls!)
                          Container(
                            width: 1300,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        detailPicUrl, // Assuming 'picUrl' is the key for the image
                                        width: double.infinity,
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ),
                          ),
                      SizedBox(height: 16),
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Type', style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 800 ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 24 : 20),
                      // Bottom Container
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('그린워싱 유형', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                                          color: Color(0xff1a5545),
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      Text('이란?', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 15,
                                        )
                                      ),
                                    ]
                                  ),
                                  SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Text('캐나다의 친환경 컨설팅 기업 ', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                        )
                                      ),
                                      Text('테라초이스', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                          color: Color(0xff1a5545),
                                        )
                                      ),
                                      Text('에서 발표한 그린워싱의 유형입니다.', style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                        )
                                      ),
                                    ]
                                  ),
                                  Text('그린리버에서는 총 7가지의 유형 중, 소비자가 직관적으로 판단할 수 있는', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  Text('4가지를 선정하여 제시하고 있습니다.', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.width > 800 ? 50 : 25),
                                  Text('증거 불충분', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 21 : 11,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('친환경 제품임을 증명할 인증 라벨이나 성분 등의 증거가', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  Text('제대로 마련되지 않은 경우입니다.', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('부적절한 인증 라벨', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 21 : 11,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('공인된 인증 마크와 유사한 이미지를 부착하는 경우입니다.', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('애매모호한 주장', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 21 : 11,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('뜻을 이해하기 어렵거나 오해를 불러 일으킬 수 있는 문구를 사용하는 경우입니다.', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('거짓말', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 21 : 11,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('인증마크나 문구를 도용하여 사실이 아닌 부분을 광고하는 경우입니다.', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 8,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                ],
                              ),
                            ),
                            if (MediaQuery.of(context).size.width > 800)
                              Column(
                                children: [
                                  SizedBox(height: 50),
                                  Container(
                                    height: 650,
                                    width: 0.08, // 세로선의 두께 설정
                                    color: Color(0xFFDCDCDC), // 세로선의 색상 설정
                                  ),
                                ]
                              ),
                            if (MediaQuery.of(context).size.width > 800)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 600,
                                      width: double.infinity, // 세로선의 두께 설정
                                      child: Center(
                                        child: DonutChart()
                                      )
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (MediaQuery.of(context).size.width <= 800)
                        Container(
                          width: 1300,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 450,
                                      width: MediaQuery.of(context).size.width - 20, // 세로선의 두께 설정
                                      child: Center(
                                        child: DonutChart()
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ]
                          )
                        ),
                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 24),
                      // Reviews
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Review', style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 800 ? 32 : 24,
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 16),
                                      Text('${productReviews.length} Cases', style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        )
                                      ),
                                    ]
                                  ),
                                ]
                              ),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 60 : 40),
                      // Review List
                      // You can use productReviews to build a ListView of reviews
                      // Assuming productReviews is a List<dynamic>
                      if (productReviews != null)
                        for (int i = 5 * (context.read<GlobalStore>().reviewPage - 1); i < productReviews!.length && i < 5 * (context.read<GlobalStore>().reviewPage); i++)
                          Container(
                            width: 1300,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // User Icon and Name
                                          CircleAvatar(
                                            // Assuming user icon is available in the review data
                                            radius: MediaQuery.of(context).size.width > 800 ? 24.0 : 22.0,
                                            backgroundImage: NetworkImage('https://www.iconpacks.net/icons/2/free-user-icon-3296-thumb.png'),
                                            backgroundColor: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(productReviews[i]['name'], style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.width > 800 ? 20 : 14,
                                                  fontWeight: FontWeight.bold,
                                                )
                                              ),
                                              Text(' ', style: TextStyle(
                                                  fontSize: 5,
                                                )
                                              ),
                                              Row(
                                                children: [
                                                  if (productReviews[i]['checklists'][0] == 1)
                                                    if (productReviews[i]['checklists'][1] == 0 && productReviews[i]['checklists'][2] == 0 && productReviews[i]['checklists'][3] == 0)
                                                      Text('증거 불충분', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('증거 불충분 | ', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (productReviews[i]['checklists'][1] == 1)
                                                    if (productReviews[i]['checklists'][2] == 0 && productReviews[i]['checklists'][3] == 0)
                                                      Text('부적절한 인증 라벨', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('부적절한 인증 라벨 | ', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (productReviews[i]['checklists'][2] == 1)
                                                    if (productReviews[i]['checklists'][3] == 0)
                                                      Text('애매모호한 주장', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('애매모호한 주장 | ', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (productReviews[i]['checklists'][3] == 1)
                                                    Text('거짓말', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (productReviews[i]['checklists'][0] == 0 && productReviews[i]['checklists'][1] == 0 && productReviews[i]['checklists'][2] == 0 && productReviews[i]['checklists'][3] == 0)
                                                    Text('해당사항 없음', style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 9,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                ],
                                              ),
                                            ]
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Provider.of<GlobalStore>(context, listen: false).review_id = '${productReviews[i]['review_id']}';
                                                    Provider.of<GlobalStore>(context, listen: false).isDialogOpen = true;
                                                    Provider.of<GlobalStore>(context, listen: false).isDelete = true;
                                                    widget.onPageUpdate();
                                                  },
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Color(0xffb4b4b4),
                                                  ),
                                                ),
                                              ]
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 24),
                                      Row(
                                        children: [
                                          SizedBox(width: MediaQuery.of(context).size.width > 800 ? 56 : 52),
                                          Text('${productReviews[i]['content']}', style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width > 800 ? 18 : 12,
                                            )
                                          )
                                        ]
                                      ),
                                      // Add X Button here for review deletion
                                      SizedBox(height: 20),
                                      Container(
                                        height: 0.08,
                                        width: double.infinity, // 세로선의 두께 설정
                                        color: Color(0xFFDCDCDC), // 세로선의 색상 설정
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                )
                              ]
                            ),
                          ),
                      // Page Navigation for Reviews
                      PageNavigation(
                        currentPage: context.read<GlobalStore>().reviewPage,
                        totalPages: (productReviews!.length - 1) ~/ 5 + 1,
                        onPageChanged: (page) {
                          // print("-----Detetct-@@---${page}");
                          if(page != context.read<GlobalStore>().reviewPage) {
                            Provider.of<GlobalStore>(context, listen: false).reviewPage = page;
                            Provider.of<GlobalStore>(context, listen: false).reviewPageChange = true;
                            // print("-----Change-@@---${context.read<GlobalStore>().reviewPage}");
                            setState(() {});
                            widget.onPageUpdate();
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      // Write Review Button
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(width:16)
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Handle Purchase button click
                                if (!context.read<GlobalStore>().isDialogOpen) {
                                  // print("Open");
                                  Provider.of<GlobalStore>(context, listen: false).isDialogOpen = true;
                                  widget.onPageUpdate();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff19583E), // 배경색
                                onPrimary: Color(0xff19583E), // 텍스트 및 아이콘 색상
                                side: BorderSide(color: Color(0xff19583E)), // 테두리 색상 및 너비
                                minimumSize: Size(MediaQuery.of(context).size.width > 800 ? 130 : 110, MediaQuery.of(context).size.width > 800 ? 58 : 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0), // 모서리를 둥글게 하는 정도를 지정
                                ),
                              ),
                              child: Text('리뷰 작성', style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 800 ? 16 : 14,
                                  color: Colors.white,
                                )
                              ),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width > 800 ? 32 : 24),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

class DonutChart extends StatefulWidget {
  const DonutChart({super.key});

  @override
  State<StatefulWidget> createState() => DonutChartState();
}

class DonutChartState extends State<DonutChart> {
  int touchedIndex = -1;
  int tempIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 28,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Indicator(
                color: Color(0xFFe9ec85), // 대체 색상 값
                text: '증거 불충분',
                isSquare: true,
                size: tempIndex == 0 ? (MediaQuery.of(context).size.width > 800 ? 11 : 8) : (MediaQuery.of(context).size.width > 800 ? 10 : 7),
                textColor: tempIndex == 0 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFF7cc9af), // 대체 색상 값
                text: '부적절한 인증 라벨',
                isSquare: true,
                size: tempIndex == 1 ? (MediaQuery.of(context).size.width > 800 ? 11 : 8) : (MediaQuery.of(context).size.width > 800 ? 10 : 7),
                textColor: tempIndex == 1 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFFfeb59c), // 대체 색상 값
                text: '애매모호한 주장',
                isSquare: true,
                size: tempIndex == 2 ? (MediaQuery.of(context).size.width > 800 ? 11 : 8) : (MediaQuery.of(context).size.width > 800 ? 10 : 7),
                textColor: tempIndex == 2 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFF9e9ac9), // 대체 색상 값
                text: '거짓말',
                isSquare: true,
                size: tempIndex == 3 ? (MediaQuery.of(context).size.width > 800 ? 11 : 8) : (MediaQuery.of(context).size.width > 800 ? 10 : 7),
                textColor: tempIndex == 3 ? Colors.black : Colors.grey,
              ),
            ],
          ),
          if (MediaQuery.of(context).size.width > 800)
            const SizedBox(
              height: 70,
            ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] == 0) ? Container() : PieChart(
                PieChartData(
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 1,
                  centerSpaceRadius: MediaQuery.of(context).size.width > 800 ? 150 : 70,
                  sections: showingSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          tempIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      4,
      (i) {
        tempIndex = touchedIndex;
        // print(touchedIndex);
        if (tempIndex != -1) {
          if (context.read<GlobalStore>().checklists[0] == 0) {
            tempIndex = tempIndex + 1;
          }
          if (context.read<GlobalStore>().checklists[1] == 0 && tempIndex > 0) {
            tempIndex = tempIndex + 1;
          }
          if (context.read<GlobalStore>().checklists[2] == 0 && tempIndex > 1) {
            tempIndex = tempIndex + 1;
          }
          if (context.read<GlobalStore>().checklists[3] == 0 && tempIndex > 2) {
            tempIndex = tempIndex + 1;
          }
        }
        // if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   tempIndex = touchedIndex + 1;
        // }
        // else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   if (touchedIndex > 0) {
        //     tempIndex = touchedIndex + 1;
        //   }
        // }
        // else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   if (touchedIndex > 1) {
        //     tempIndex = touchedIndex +1;
        //   }
        // }
        // else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   tempIndex = touchedIndex + 2;
        // }
        // else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   if (touchedIndex > 0) {
        //     tempIndex = touchedIndex + 2;
        //   }
        // }
        // else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   if (touchedIndex == 0) {
        //     tempIndex = touchedIndex + 1;
        //   }
        //   else {
        //     tempIndex = touchedIndex + 2;
        //   }
        // }
        // else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
        //   tempIndex = touchedIndex + 3;
        // }
        final isTouched = i == tempIndex;
        if (i == 0 && context.read<GlobalStore>().checklists[0] != 0) {
          return PieChartSectionData(
            color: isTouched ? Color(0xffFAFA4A) : Color(0xFFe9ec85), // 대체 색상 값
            value: context.read<GlobalStore>().checklists[0],
            title: isTouched ? context.read<GlobalStore>().checklists[0].round().toString() : '',
            titleStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 18,
              color: Colors.grey,
            ),
            radius: MediaQuery.of(context).size.width > 800 ? 140 : 110,
            titlePositionPercentageOffset: 0.55,
            borderSide: isTouched
                ? const BorderSide(
                    color: Colors.white, width: 2)
                : BorderSide(color: Colors.white, width: 4),
          );
        }
        if (i == 1 && context.read<GlobalStore>().checklists[1] != 0) {
          return PieChartSectionData(
            color: isTouched ? Color(0xff4dd7a4) : Color(0xFF7cc9af), // 대체 색상 값
            value: context.read<GlobalStore>().checklists[1],
            title: isTouched ? context.read<GlobalStore>().checklists[1].round().toString() : '',
            titleStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 18,
              color: Color(0xffFFFFFF),
            ),
            radius: MediaQuery.of(context).size.width > 800 ? 140 : 110,
            titlePositionPercentageOffset: 0.55,
            borderSide: isTouched
                ? const BorderSide(
                    color: Colors.white, width: 2)
                : BorderSide(color: Colors.white, width: 4),
          );
        }
        if (i == 2 && context.read<GlobalStore>().checklists[2] != 0) {
          return PieChartSectionData(
            color: isTouched ? Color(0xfffe9772) : Color(0xFFfeb59c), // 대체 색상 값
            value: context.read<GlobalStore>().checklists[2],
            title: isTouched ? context.read<GlobalStore>().checklists[2].round().toString() : '',
            titleStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 18,
              color: Color(0xffFFFFFF),
            ),
            radius: MediaQuery.of(context).size.width > 800 ? 140 : 110,
            titlePositionPercentageOffset: 0.6,
            borderSide: isTouched
                ? const BorderSide(
                    color: Colors.white, width: 2)
                : BorderSide(color: Colors.white, width: 4),
          );
        }
        if (i == 3 && context.read<GlobalStore>().checklists[3] != 0) {
          return PieChartSectionData(
            color: isTouched ? Color(0xff8274cb) : Color(0xFF9e9ac9), // 대체 색상 값
            value: context.read<GlobalStore>().checklists[3],
            title: isTouched ? context.read<GlobalStore>().checklists[3].round().toString() : '',
            titleStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 18,
              color: Color(0xffFFFFFF),
            ),
            radius: MediaQuery.of(context).size.width > 800 ? 140 : 110,
            titlePositionPercentageOffset: 0.55,
            borderSide: isTouched
                ? const BorderSide(
                    color: Colors.white, width: 2)
                : BorderSide(color: Colors.white, width: 4),
          );
        }
        return PieChartSectionData(
          color: Colors.transparent,  // 또는 적절한 기본값 설정
          value: 0,  // 또는 적절한 기본값 설정
          title: isTouched ? '32' : '',
            titleStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 800 ? 25 : 18,
              color: Color(0xffFFFFFF),
            ),
          radius: 0,
          titlePositionPercentageOffset: 0,
          borderSide: BorderSide.none,
        );
      },
    );
  }
}

class PageNavigation extends StatelessWidget {
  int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  PageNavigation({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    const int maxVisiblePages = 7;

    int startPage = 0;
    int endPage = 0;
    if (context.read<GlobalStore>()._isDetail) {
      startPage = max(1, min(context.read<GlobalStore>().reviewPage - (maxVisiblePages ~/ 2), totalPages - maxVisiblePages + 1));
      endPage = min(totalPages, startPage + maxVisiblePages - 1);
    }
    else {
      startPage = max(1, min(currentPage - (maxVisiblePages ~/ 2), totalPages - maxVisiblePages + 1));
      endPage = min(totalPages, startPage + maxVisiblePages - 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int page = startPage; page <= endPage; page++)
            GestureDetector(
              onTap: () {
                onPageChanged(page);
                // print('startpage: ${startPage}');
                // print('endpage: ${endPage}');
                // print('currentpage: ${currentPage}');
                // print('reviewpage: ${context.read<GlobalStore>().reviewPage}');
                // print('page: ${page}');
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: (currentPage == page) ? 18.0 : 16.0,
                    fontWeight: (currentPage == page) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Product {
  final String productID;
  final String productName;
  final String vendor;
  final String thumbnail;
  final int reviewCount;
  final int state;
  final String price;

  Product({
    required this.productID,
    required this.thumbnail,
    required this.productName,
    required this.vendor,
    required this.reviewCount,
    required this.state,
    required this.price,
  });
}

class CustomPieChartSectionData {
  final double value;
  final Color color;
  final String title;
  final double radius;

  CustomPieChartSectionData({
    required this.value,
    required this.color,
    required this.title,
    required this.radius,
  });
}

class GlobalStore extends ChangeNotifier{
  List<Product> products = [];
  int currentPage = 1;
  int reviewPage = 1;
  String detailID = "";
  bool _isDetail = false;
  bool _isHover = false;
  bool _pageChangeDetect = false;
  List<double> checklists = [1.0, 1.0, 1.0, 1.0];
  bool isDialogOpen = false;
  double _scrollValue = 0.0;
  String detail_id = "";
  String review_id = "";
  bool reviewPageChange = false;
  bool initReview = false;
  bool goReview = false;
  bool isDelete = false;
}

Future<List<Product>> fetchProducts(String searchword) async {
  // print('Search Word: ${searchword}');
  String url =
      'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/search?searchword=$searchword&page=1&size=100';
  // print(url);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    List<Product> products = responseData.map((data) {
      int state = 0; // Grey
      int reviewCount = int.tryParse(data['reviewer']) ?? 0;
      String price = translatePrice(data['price']);
      if (reviewCount > 0) {
        var checklist = json.decode(data['checklists']);
        var warnValue = (checklist[0] + checklist[1] + checklist[2] + checklist[3]) / (reviewCount * 4);
        if (warnValue < 0.25) { 
          state = 1; // Green
        }
        else if (warnValue < 0.6) { 
          state = 2; // Yellow
        }
        else {
          state = 3; // Red
        }
      }

      return Product(
        productID: data['id'],
        productName: data['name'],
        vendor: data['vendor'],
        thumbnail: data['picThumbnail'],
        reviewCount: reviewCount,
        state: state,
        price: price,
      );
    }).toList();

    return products;
  } else {
    throw Exception('Failed to load products');
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width > 800 ? size * 4 : size * 2,
          height: size * 1,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 800 ? 13 : 8,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        )
      ],
    );
  }
}

// 23456789 -> 23,456,789 (가격에 구분자 추가))
String translatePrice(String inputString) {
  StringBuffer middleBuffer = StringBuffer();
  StringBuffer resultBuffer = StringBuffer();
  int j = 0;
  for (int i = inputString.length-1; i >= 0 ; i--) {
    middleBuffer.write(inputString[i]);
    if (j == 2 && i != 0) {
      middleBuffer.write(',');
    }
    j = (j + 1) % 3;
  }
  String middleString = middleBuffer.toString();

  // Reverse
  for (int i = middleString.length-1; i >= 0 ; i--) {
    resultBuffer.write(middleString[i]);
  }
  return resultBuffer.toString();
}