# Client

# Server

## Facade Server API

### 1. Product Info

#### 1) Search API [GET]

<aside>
📌 http://facadeserver:8080/search?searchword=${searchword}&page=${page}&size=${size}

</aside>

-   Request

```
- 검색어
- 0부터 시작하는 페이지 번호
- 페이지 크기
```

-   Response

```
[
    {
        id: '13078',
        picUrl: 'http://image1.jpg',
        name: ' 친환경 종이컵 10온스',
        vendor: 'CafenTea',
        price: '4950',
        reviewer: '12',
        warningState: 2
    },
    {
        id: '52048',
        picUrl: 'http://image2.jpg',
        name: ' 샴풍 일회용컵',
        vendor: 'CafenTea',
        price: '4950',
    ...
```

#### 2) Search Length API [GET]

<aside>
📌 http://facadeserver:8080/search/length?searchword=${searchword}

</aside>

-   Request

```
- 검색어
```

-   Response

```
{
    length: 11
}
```

#### 3) Detail API [GET]

<aside>
📌 http://facadeserver:8080/detail?id=${product_id}

</aside>

-   Request

```
- 상품 id
```

-   Response

```
{
    id: '13078',
    picUrl: 'http://image1.jpg',
    name: ' 친환경 종이컵 10온스',
    vendor: 'CafenTea',
    price: '4950',
    deliveryFee: '3000',
    originalUrl: 'http://shop.com',
    reviewer: '12',
    checklists: '[3,2,7,0]',
    detailpicUrl: [
        'http://image1.jpg',
        'http://image2.jpg',
        'http://image3.jpg',
        ...
    ]
}

```

### 2. Review Info

#### 1) Review Content API [GET]

<aside>
📌 http://facadeserver:8080/review/content?id=${product_id}&page=${page}&size=${size}

</aside>

-   Request

```
- 상품 id
- 리뷰 페이지 번호
- 리뷰 페이지 크기
```

-   Response

```
[
    {
        review_id: 57,
        name: 'John',
        content: ' This is good.',
        checklists: '[0,0,1,0]'
    },
    {
        review_id: 81,
        name: 'Steve',
        content: ' Not too bad.',
        checklists: '[0,1,0,1]'
    },
    {
        review_id: 103,
        name: 'Jenny',
        ...
```

#### 2) Review Write API [POST]

<aside>
📌 http://facadeserver:8080/review/write

```
{
    id: ${product_id},
    name: ${name},
    password: ${password},
    checklists: ${checklists},
    content: ${content}
}
```

</aside>

-   Request

```
- 상품 id
- 리뷰 작성자명
- 리뷰 작성시 비밀번호
- 체크리스트
- 리뷰 내용
```

-   Response

```
success
```

#### 3) Review Delete API [DELETE]

<aside>
📌 http://facadeserver:8080/review/delete?id=${review_id}&password=${password}

</aside>

-   Request

```
- 리뷰 id
- 리뷰 작성시 비밀번호
```

-   Response

```
success
```

```
WrongPassword
```

## 2. Conversion Server

#### 1) Product Search API [GET]

<aside>
📌 http://conversionserver:8082/search?searchword=${searchword}&page=${page}&size=${size}

</aside>

-   Request

```
- 검색어
- 0부터 시작하는 페이지 번호
- 페이지 크기
```

-   Response

```
[
    {
        id: '13078',
        picUrl: 'http://image1.jpg',
        name: ' 친환경 종이컵 10온스',
        vendor: 'CafenTea',
        price: '4950',
        reviewer: '12',
        warningState: 2
    },
    {
        id: '52048',
        picUrl: 'http://image2.jpg',
        name: ' 샴풍 일회용컵',
        vendor: 'CafenTea',
        price: '4950',
    ...
```

#### 2) Product Search Length API [GET]

<aside>
📌 http://conversionserver:8082/search/length?searchword=${searchword}

</aside>

-   Request

```
- 검색어
```

-   Response

```
{
    length: 11
}
```

#### 3) Product Detail API [GET]

<aside>
📌  http://conversionserver:8082/detail?id=${product_id}

</aside>

-   Request

```
- 상품 id
```

-   Response

```
{
    id: '13078',
    picUrl: 'http://image1.jpg',
    name: ' 친환경 종이컵 10온스',
    vendor: 'CafenTea',
    price: '4950',
    deliveryFee: '3000',
    originalUrl: 'http://shop.com',
    reviewer: '12',
    checklists: '[3,2,7,0]',
    detailpicUrl: [
        'http://image1.jpg',
        'http://image2.jpg',
        'http://image3.jpg',
        ...
    ]
}

```

### 2. Review Info

#### 1) Product Review Write API [POST]

<aside>
📌 http://conversionserver:8082/review/write

```
{
    id: ${product_id},
    name: ${name},
    password: ${password},
    checklists: ${checklists},
    content: ${content}
}
```

</aside>

-   Request

```
- 상품 id
- 리뷰 작성자명
- 리뷰 작성시 비밀번호
- 체크리스트
- 리뷰 내용
```

-   Response

```
success
```

#### 2) Product Review Delete API [DELETE]

<aside>
📌 http://conversionserver:8082/review/delete?id=${review_id}&password=${password}

</aside>

-   Request

```
- 리뷰 id
- 리뷰 작성시 비밀번호
```

-   Response

```
success
```

```
WrongPassword
```

## 3. Database Server

### 1. Product Info

#### 1) Product Search API [GET]

<aside>
📌 http://dbserver:8081/search?keyword=${keyword}&page=${page}&size=${size}

</aside>

-   Request

```
- 키워드
- 0부터 시작하는 페이지 번호
- 페이지 크기
```

-   Response

```
[
    {
        id: '13078',
        picUrl: 'http://image1.jpg',
        name: ' 친환경 종이컵 10온스',
        vendor: 'CafenTea',
        price: '4950',
        reviewer: '12',
        warningState: 2
    },
    {
        id: '52048',
        picUrl: 'http://image2.jpg',
        name: ' 샴풍 일회용컵',
        vendor: 'CafenTea',
        price: '4950',
    ...
```

#### 2) Product Length API [GET]

<aside>
📌 http://dbserver:8081/length?keyword=${keyword}

</aside>

-   Request

```
- 키워드
```

-   Response

```
{
    length: 11
}
```

#### 3) Product Keywords API [GET]

<aside>
📌 http://dbserver:8081/keywords

</aside>

-   Request

```
- X
```

-   Response

```
{
    keywords: [
        '샴푸',
        '세제',
        '페인트',
        '우유',
        '토마토',
        '접시',
        '젓가락',
        '채소',
        '비닐',
        '호일',
        '차',
        '계란',
        '수세미',
        '휴지',
        ...
```

#### 4) Product Detail Content API [GET]

<aside>
📌 http://dbserver:8081/detail/content?id=${product_id}

</aside>

-   Request

```
- 상품 id
```

-   Response

```
{
    id: '13078',
    picUrl: 'http://image1.jpg',
    name: ' 친환경 종이컵 10온스',
    vendor: 'CafenTea',
    price: '4950',
    deliveryFee: '3000',
    originalUrl: 'http://shop.com',
    reviewer: '12',
    checklists: '[3,2,7,0]'
}
```

#### 5) Product Detail Image API [GET]

<aside>
📌 http://dbserver:8081/detail/image?id=${product_id}

</aside>

-   Request

```
- 상품 id
```

-   Response

```
{
    detailpicUrl: [
        'http://image1.jpg',
        'http://image2.jpg',
        'http://image3.jpg',
        'http://image4.jpg',
        'http://image5.jpg',
        'http://image6.jpg',
        'http://image7.jpg',
        'http://image8.jpg',
        'http://image9.jpg',
        'http://image10.jpg',
        'http://image11.jpg',
        'http://image12.jpg',
        'http://image13.jpg',
        'http://image14.jpg',
        ...
```

#### 6) Product Item Table Update API [PUT]

<aside>
📌 http://dbserver:8081/update

```
{
    id: ${product_id},
    check_1: ${check_1},
    check_2: ${check_2},
    check_3: ${check_3},
    check_4: ${check_4},
    reviewer: ${reviewer}
}
```

</aside>

-   Request

```
- 상품 id
- 1번째 체크리스트 전체 체크 수
- 2번째 체크리스트 전체 체크 수
- 3번째 체크리스트 전체 체크 수
- 4번째 체크리스트 전체 체크 수
- 리뷰 작성자 수
```

-   Response

```
success
```

### 2. Review Info

#### 1) Product Review Content API [GET]

<aside>
📌 http://dbserver:8081/review/content?id=${product_id}&page=${page}&size=${size}

</aside>

-   Request

```
- 상품 id
- 리뷰 페이지 번호
- 리뷰 페이지 크기
```

-   Response

```
[
    {
        review_id: 57,
        name: 'John',
        content: ' This is good.',
        checklists: '[0,0,1,0]'
    },
    {
        review_id: 81,
        name: 'Steve',
        content: ' Not too bad.',
        checklists: '[0,1,0,1]'
    },
    {
        review_id: 103,
        name: 'Jenny',
        ...
```

#### 2) Product Review Length API [GET]

<aside>
📌 http://dbserver:8081/review/length?id=${product_id}

</aside>

-   Request

```
- 상품 id
```

-   Response

```
{
    length: 8
}
```

#### 3) Product Review Password API [GET]

<aside>
📌 http://dbserver:8081/review/password?id=${review_id}

</aside>

-   Request

```
- 리뷰 id
```

-   Response

```
{
    password: 1234
}
```

#### 4) Product Review Write API [POST]

<aside>
📌 http://dbserver:8081/review/write

```
{
    id: ${product_id},
    name: ${name},
    password: ${password},
    check_1: ${check_1},
    check_2: ${check_2},
    check_3: ${check_3},
    check_4: ${check_4},
    content: ${content}
}
```

</aside>

-   Request

```
- 상품 id
- 리뷰 작성자명
- 리뷰 작성시 비밀번호
- 1번째 체크리스트 체크 여부
- 2번째 체크리스트 체크 여부
- 3번째 체크리스트 체크 여부
- 4번째 체크리스트 체크 여부
- 리뷰 내용
```

-   Response

```
success
```

#### 5) Product Review Delete API [DELETE]

<aside>
📌 http://dbserver:8081/review/delete?id=${review_id}

</aside>

-   Request

```
- 리뷰 id
```

-   Response

```
success
```

## 4. Checklists

```
1. 증거 불충분
2. 애매모호한 주장
3. 거짓말
4. 부적절한 인증 라벨
```

## 5. Exception Handler

-   HTTP Error Code 404

-   Response

```
404 Error: Page Not Found
```
