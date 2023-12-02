import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SearchBarWidget(),
            Expanded(
              child: ProductList(pageItemNumber: 10), // Adjust the number as needed
            ),
          ],
        ),
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
    print('로고 이미지 클릭!');
  }

  void _updateSearchResult(String searchword) {
    setState(() {
      _searchResult = '검색 결과: $searchword';
      print(_searchResult);
    });
  }
}

class ProductList extends StatefulWidget {
  final int pageItemNumber;

  ProductList({required this.pageItemNumber});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int _hoveredIndex = -1;
  int currentPage = 1;
  late List<Product> products;

  @override
  void initState() {
    super.initState();
    // Initialize the products list when the state is created
    initializeProducts();
  }

  void initializeProducts() async {
    List<Product> initialProducts = await fetchProducts('휴지');
    setState(() {
      products = initialProducts;
    });
  }

  Future<List<Product>> fetchProducts(String searchword) async {
    print('Search Word: ${searchword}');
    String url =
        'http://ec2-3-38-236-34.ap-northeast-2.compute.amazonaws.com:8080/search?searchword=$searchword&page=1&size=100';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the products
      final List<dynamic> responseData = json.decode(response.body);

      // Map the response data to a list of Product objects
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
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load products');
    }
  }

  void updateProductDetails() async {
    // Replace this with your logic to update product details based on the current page
    setState(() async {
      List<Product> updatedProducts = await fetchProducts('휴지');
      products = updatedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: (currentPage == (products.length) ~/ 8 + 1) ? (products.length % 8) + 1  : 9, // Add 1 for the PageNavigation
            itemBuilder: (context, index) {
              if (index == 8 || (currentPage == (products.length) ~/ 8 + 1 && index == products.length % 8)) {
                // This is the last item, add the PageNavigation
                return PageNavigation(
                  currentPage: currentPage,
                  totalPages: (products.length) ~/ 8 + 1, // Change this to the actual total number of pages
                  onPageChanged: (page) {
                    setState(() {
                      currentPage = page;
                      updateProductDetails(); // Call the method to update product details
                    });
                  },
                );
              }

              return MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _hoveredIndex = index;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoveredIndex = -1;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: index == 0 ? BorderSide(color: Color(0xFFDCDCDC)) : BorderSide.none,
                        bottom: BorderSide(color: Color(0xFFDCDCDC)),
                      ),
                      color: _hoveredIndex == index ? Color(0xFFF5F5F5) : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Left Section: Product Image
                        Container(
                          width: 256.0,
                          height: 256.0,
                          child: Image.network(
                            products[(currentPage - 1) * 8 + index].thumbnail,
                            width: 128.0,
                            height: 128.0,
                            fit: BoxFit.cover, // Adjust the BoxFit as needed
                          ),
                        ),
                        // Center Section: Product Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  products[(currentPage - 1) * 8 + index].productName,
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                Text('Vendor: ${products[(currentPage - 1) * 8 + index].vendor}'),
                                SizedBox(height: 32),
                                Text('Review Count: ${products[(currentPage - 1) * 8 + index].reviewCount}'),
                              ],
                            ),
                          ),
                        ),

                        // Right Section: Additional Information
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('State: ${products[(currentPage - 1) * 8 + index].state}'),
                            Text('Price: ${products[(currentPage - 1) * 8 + index].price.toStringAsFixed(0)}'),
                          ],
                        ),
                      ],
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
}

class PageNavigation extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  PageNavigation({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    const int maxVisiblePages = 7; // Adjust the number of visible pages as needed

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
