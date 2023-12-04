import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: WholeScreen(),
      ),
    );
  }
}

class WholeScreen extends StatefulWidget {
  @override
  _WholeScreenState createState() => _WholeScreenState();
}

class _WholeScreenState extends State<WholeScreen> {
  // Add ScrollController
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          onSearchResultUpdate: () {
            // Scroll to top when search result updates
            if (context.read<GlobalStore>()._pageChangeDetect == true) {
              _scrollController.jumpTo(0.0);
              Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = false;
            }
            else {
              _scrollController.animateTo(0, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: ProductList(
            pageItemNumber: 10,
            scrollController: _scrollController, // Pass the ScrollController to ProductList
            onPageUpdate: () {
              // 페이지가 업데이트될 때 맨 위로 스크롤
              if (context.read<GlobalStore>()._pageChangeDetect == true) {
                _scrollController.jumpTo(0.0);
                Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = false;
              }
              else {
                _scrollController.animateTo(0, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
              }
              setState(() {});
            },
          ),
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
      child: Row(
        children: [
          SizedBox(width: 32),
          GestureDetector(
            onTap: _onLogoClick,
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // Change cursor shape to indicate clickability
              child: Image.asset('assets/logo.png', width: 128, height: 64),
            ),
          ),
          SizedBox(width: 32),
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
          SizedBox(width: 32),
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
      print('제품을 가져오는 중 오류 발생: $e');
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
                    SizedBox(height: 32.0),
                    Text('No Such Items'),
                    SizedBox(height: 32.0),
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
                      Provider.of<GlobalStore>(context, listen: false)._isDetail = true;
                      Provider.of<GlobalStore>(context, listen: false)._pageChangeDetect = true;
                      Provider.of<GlobalStore>(context, listen: false).detailID = context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + _hoveredIndex].productID;
                      widget.onPageUpdate();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: context.read<GlobalStore>()._isDetail ? _detailScreen() : Container( 
                      // Product List View
                      width: 2000,
                      decoration: BoxDecoration(
                        border: Border(
                          top: index == 0 ? BorderSide(color: Color(0xFFDCDCDC)) : BorderSide.none,
                          bottom: BorderSide(color: Color(0xFFDCDCDC)),
                        ),
                        color: (_hoveredIndex == index && context.read<GlobalStore>()._isHover == true) ? Color(0xFFF5F5F5) : Colors.transparent,
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                            Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 256.0,
                                  height: 256.0,
                                  child: Image.network(
                                    context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].thumbnail,
                                    width: 128.0,
                                    height: 128.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].productName,
                                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text('${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].vendor}'),
                                        SizedBox(height: 32),
                                        Text('Reviews: ${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].reviewCount}'),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('State: ${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].state}'),
                                    Text('${context.read<GlobalStore>().products[(context.read<GlobalStore>().currentPage - 1) * 8 + index].price.toStringAsFixed(0)}￦'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                      )
                    ),
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
            var productPrice = detailJson['price'];
            var productDeliveryFee = detailJson['deliveryFee'];
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
            print(context.read<GlobalStore>().checklists);
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
                  productReviews = json.decode(json.decode(reviewSnapshot.data!));
                  print(productReviews);

                  // 이제 로딩된 데이터를 포함한 Column을 반환할 수 있습니다.
                  return Column(
                    children: [
                      // Top Container with Image
                      Container(
                        width: 1300, // You can adjust the height as needed
                        height: 600, // You can adjust the height as needed
                        child: Row(
                          children: [
                            Expanded(
                              child: Image.network(
                                detailJson['picUrl'], // Assuming 'picUrl' is the key for the image
                                width: 600,
                                height: 600,
                              ),
                            ),
                            SizedBox(width: 16), // Adjust the spacing as needed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(productName, style: TextStyle(
                                          fontSize: 45,
                                        )
                                      ),
                                      Text(productVendor, style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.grey, 
                                        )
                                      ),
                                      Text('리뷰 수: ${productReviews.length}', style: TextStyle(
                                          fontSize: 22,
                                          color: Color(0xff469174),
                                        )
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(height: 16),
                                  SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('배송비: ${productDeliveryFee}원', style: TextStyle(
                                          fontSize: 23,
                                        )
                                      ),
                                      SizedBox(height: 14),
                                      Text('${productPrice}원', style: TextStyle(
                                          fontSize: 27,
                                          color: Color(0xffa1b87e),
                                        )
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle Purchase button click
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xffbfd0a6), // 배경색
                                              onPrimary: Color(0xffbfd0a6), // 텍스트 및 아이콘 색상
                                              side: BorderSide(color: Color(0xffbfd0a6)), // 테두리 색상 및 너비
                                              minimumSize: Size(300, 64),
                                            ),
                                            child: Text('구매하기', style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                              )
                                            ),
                                          ),
                                          SizedBox(width: 32),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle Check Review button click
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white, // 배경색
                                              onPrimary: Colors.white, // 텍스트 및 아이콘 색상
                                              side: BorderSide(color: Color(0xffbfd0a6)), // 테두리 색상 및 너비
                                              minimumSize: Size(300, 64),
                                            ),
                                            child: Text('리뷰확인', style: TextStyle(
                                                fontSize: 24,
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
                      SizedBox(height: 16),
                      /*
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
                      */
                      SizedBox(height: 16),
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Type', style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: 12),
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
                                          fontSize: 25,
                                          color: Color(0xff1a5545),
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      Text('이란?', style: TextStyle(
                                          fontSize: 25,
                                        )
                                      ),
                                    ]
                                  ),
                                  SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Text('캐나다의 친환경 컨설팅 기업 ', style: TextStyle(
                                          fontSize: 18,
                                        )
                                      ),
                                      Text('테라초이스', style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xff1a5545),
                                        )
                                      ),
                                      Text('에서 발표한 그린워싱의 유형입니다.', style: TextStyle(
                                          fontSize: 18,
                                        )
                                      ),
                                    ]
                                  ),
                                  Text('그린리버에서는 총 7가지의 유형 중, 소비자가 직관적으로 판단할 수 있는', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  Text('4가지를 선정하여 제시하고 있습니다.', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  SizedBox(height: 50),
                                  Text('증거 불충분', style: TextStyle(
                                      fontSize: 21,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('친환경 제품임을 증명할 인증 라벨이나 성분 등의 증거가', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  Text('제대로 마련되지 않은 경우입니다.', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('부적절한 인증 라벨', style: TextStyle(
                                      fontSize: 21,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('공인된 인증 마크와 유사한 이미지를 부착하는 경우입니다.', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('애매모호한 주장', style: TextStyle(
                                      fontSize: 21,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('뜻을 이해하기 어렵거나 오해를 불러 일으킬 수 있는 문구를 사용하는 경우입니다.', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                  Text('거짓말', style: TextStyle(
                                      fontSize: 21,
                                      color: Color(0xff1a5545),
                                    )
                                  ),
                                  SizedBox(height: 7),
                                  Text('인증마크나 문구를 도용하여 사실이 아닌 부분을 광고하는 경우입니다.', style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  SizedBox(height: 25),
                                ],
                              ),
                            ),
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
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 600,
                                    width: double.infinity, // 세로선의 두께 설정
                                    child: Center(
                                      child: PieChartSample1()
                                    )
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      // Reviews
                      Container(
                        width: 1300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Review', style: TextStyle(
                                      fontSize: 32,
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
                      SizedBox(height: 32),
                      // Review List
                      // You can use productReviews to build a ListView of reviews
                      // Assuming productReviews is a List<dynamic>
                      if (productReviews != null)
                        for (var review in productReviews!)
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
                                            radius: 24.0,
                                            backgroundImage: NetworkImage('https://www.iconpacks.net/icons/2/free-user-icon-3296-thumb.png'),
                                            backgroundColor: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(review['name'], style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                )
                                              ),
                                              Text(' ', style: TextStyle(
                                                  fontSize: 5,
                                                )
                                              ),
                                              Row(
                                                children: [
                                                  if (review['checklists'][0] == 1)
                                                    if (review['checklists'][1] == 0 && review['checklists'][2] == 0 && review['checklists'][3] == 0)
                                                      Text('증거 불충분', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('증거 불충분 | ', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (review['checklists'][1] == 1)
                                                    if (review['checklists'][2] == 0 && review['checklists'][3] == 0)
                                                      Text('부적절한 인증 라벨', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('부적절한 인증 라벨 | ', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (review['checklists'][2] == 1)
                                                    if (review['checklists'][3] == 0)
                                                      Text('애매모호한 주장', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                    else
                                                      Text('애매모호한 주장 | ', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (review['checklists'][3] == 1)
                                                    Text('거짓말', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                  ,if (review['checklists'][0] == 0 && review['checklists'][1] == 0 && review['checklists'][2] == 0 && review['checklists'][3] == 0)
                                                    Text('해당사항 없음', style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(0xff1a5545),
                                                        )
                                                      )
                                                ],
                                              ),
                                            ]
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(width: 56),
                                          Text('${review['content']}', style: TextStyle(
                                              fontSize: 18,
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
                        currentPage: 1, // Assuming you will manage the current page
                        totalPages: 5, // Assuming you know the total number of review pages
                        onPageChanged: (page) {
                          // Handle page change
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
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff19583E), // 배경색
                                onPrimary: Color(0xff19583E), // 텍스트 및 아이콘 색상
                                side: BorderSide(color: Color(0xff19583E)), // 테두리 색상 및 너비
                                minimumSize: Size(130, 58),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0), // 모서리를 둥글게 하는 정도를 지정
                                ),
                              ),
                              child: Text('리뷰 작성', style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                )
                              ),
                            )
                          ]
                        ),
                      ),
                      SizedBox(height: 32),
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

class PieChartSample1 extends StatefulWidget {
  const PieChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State<PieChartSample1> {
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
                size: tempIndex == 0 ? 11 : 10,
                textColor: tempIndex == 0 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFF7cc9af), // 대체 색상 값
                text: '부적절한 인증 라벨',
                isSquare: true,
                size: tempIndex == 1 ? 11 : 10,
                textColor: tempIndex == 1 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFFfeb59c), // 대체 색상 값
                text: '애매모호한 주장',
                isSquare: true,
                size: tempIndex == 2 ? 11 : 10,
                textColor: tempIndex == 2 ? Colors.black : Colors.grey,
              ),
              Indicator(
                color: Color(0xFF9e9ac9), // 대체 색상 값
                text: '거짓말',
                isSquare: true,
                size: tempIndex == 3 ? 11 : 10,
                textColor: tempIndex == 3 ? Colors.black : Colors.grey,
              ),
            ],
          ),
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
                  centerSpaceRadius: 150,
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
        if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
          tempIndex = touchedIndex + 1;
        }
        else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
          if (touchedIndex > 0) {
            tempIndex = touchedIndex + 1;
          }
        }
        else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
          if (touchedIndex > 1) {
            tempIndex = touchedIndex +1;
          }
        }
        else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] != 0 && context.read<GlobalStore>().checklists[3] != 0) {
          tempIndex = touchedIndex + 2;
        }
        else if (context.read<GlobalStore>().checklists[0] != 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
          if (touchedIndex > 0) {
            tempIndex = touchedIndex + 2;
          }
        }
        else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] != 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
          if (touchedIndex == 0) {
            tempIndex = touchedIndex + 1;
          }
          else {
            tempIndex = touchedIndex + 2;
          }
        }
        else if (context.read<GlobalStore>().checklists[0] == 0 && context.read<GlobalStore>().checklists[1] == 0 && context.read<GlobalStore>().checklists[2] == 0 && context.read<GlobalStore>().checklists[3] != 0) {
          tempIndex = touchedIndex + 3;
        }
        final isTouched = i == tempIndex;
        if (i == 0 && context.read<GlobalStore>().checklists[0] != 0) {
          return PieChartSectionData(
            color: isTouched ? Color(0xffFAFA4A) : Color(0xFFe9ec85), // 대체 색상 값
            value: context.read<GlobalStore>().checklists[0],
            title: '',
            radius: 140,
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
            title: '',
            radius: 140,
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
            title: '',
            radius: 140,
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
            title: '',
            radius: 140,
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
          title: '',
          radius: 0,
          titlePositionPercentageOffset: 0,
          borderSide: BorderSide.none,
        );
      },
    );
  }
}

class PageNavigation extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  PageNavigation({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    const int maxVisiblePages = 7;

    int startPage = max(1, min(currentPage - (maxVisiblePages ~/ 2), totalPages - maxVisiblePages + 1));
    int endPage = min(totalPages, startPage + maxVisiblePages - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int page = startPage; page <= endPage; page++)
            GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: currentPage == page ? 18.0 : 16.0,
                    fontWeight: currentPage == page ? FontWeight.bold : FontWeight.normal,
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
  final double price;

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
  String detailID = "";
  bool _isDetail = false;
  bool _isHover = false;
  bool _pageChangeDetect = false;
  List<double> checklists = [1.0, 1.0, 1.0, 1.0];
}

Future<List<Product>> fetchProducts(String searchword) async {
  print('Search Word: ${searchword}');
  String url =
      'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/search?searchword=$searchword&page=1&size=100';
  print(url);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    List<Product> products = responseData.map((data) {
      int state = 0;
      int reviewCount = int.tryParse(data['reviewer']) ?? 0;
      double price = double.tryParse(data['price']) ?? 0.0;
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
          width: size * 4,
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
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        )
      ],
    );
  }
}
