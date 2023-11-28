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

```json
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
ㅤ      picUrl: 'http://image2.jpg',
        name: ' 샴풍 일회용컵',
        vendor: 'CafenTea',
        price: '4950',
    ...
```

#### 2) Search Length API [GET]

<aside>
📌 http://facadeserver:8080/search/length?searchword=${searchword}

</aside>

-   요청

```
- 검색어
```

-   반환

```json
{
    "length": 11
}
```

#### 3) Detail API [GET]

<aside>
📌 http://facadeserver:8080/detail?id=${product_id}

</aside>

-   요청

```
- 상품 id
```

-   반환

```json
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

-   요청

```
- 상품 id
- 리뷰 페이지 번호
- 리뷰 페이지 크기
```

-   반환

```json
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

```json
{
    id: ${product_id},
    name: ${name},
    password: ${password},
    checklists: ${checklists},
    content: ${content}
}
```

</aside>

-   요청

```
- 상품 id
- 리뷰 작성자명
- 리뷰 작성시 비밀번호
- 체크리스트
- 리뷰 내용
```

-   반환

```
success
```

#### 3) Review Delete API [GET]

<aside>
📌 http://facadeserver:8080/review/delete?id=${review_id}&password=${password}

</aside>

-   요청

```
- 리뷰 id
- 리뷰 작성시 비밀번호
```

-   반환

```
success
```

## 2. Conversion Server

## 3. Database Server

-   요청

```
- 상품 번호
```

-   반환

```json
{
    "id": 1,
    "pic_url": ".../...png",
    "name": "레모나",
    "vendor": "일동제약",
    "price": 3000,
    "deliveryFee": 0,
    "originalURL": "https://...",
    "reviewer": 30,
    "checklists": [
        {
            "id": 1,
            "num": 2
        },
        {
            "id": 2,
            "num": 2
        }
    ]
}
```

#### 2) 상품 체크리스트 조회 (GET)

<aside>
📌 example.com/product/checklist/${ID}

</aside>

-   요청

```
- 상품 번호
```

-   반환

```json
{
    "id": 1,
    "checklists": [
        {
            "id": 1,
            "num": 2
        },
        {
            "id": 2,
            "num": 2
        }
    ]
}
```

-   체크리스트

```kotlin
1. 증거 불충분
2. 애매모호한 주장
3. 거짓말
4. 부적절한 인증 라벨
```

---

`**리뷰 관련**`

#### 2) 리뷰 조회 (GET)

<aside>
📌 example.com/review/list/${ID}?page=${page}&size=${size}

</aside>

-   요청

```
- 상품 번호
- 0부터 시작하는 페이지 번호
- 페이지 크기
```

-   반환

```json
[
    {
        "id": 1,
        "content": "좋아요",
        "checkTypes": [1, 2, 3]
    }
]
```

#### 3) 리뷰 작성 (POST)

<aside>
📌 example.com/review/write

</aside>

-   요청

```
- 상품 번호 (**productId** : Int)
- 닉네임 (**nickname** : String) (나중에 교체)
- 내용 (**content** : String)
- 체크리스트 해당 여부 <- [1, 2 ...] (**checkTypes** : List<Int>)
```

-   반환

```json
{ "id": 1 }
```

#### 4) 리뷰 삭제 (DELETE) - 미구현

<aside>
📌 example.com/review/delete

</aside>

-   요청

```
- 닉네임 (**nickname** : String) (나중에 교체)
```

-   반환

```json
{ "id": 1 }
```

---

### 5) 체크리스트 조회 (GET)

<aside>
📌 example.com/checklists

</aside>

-   요청

```
- 상품 ID
```

-   반환

```json
[
    {
        "id": 1,
        "name": "증거 불충분"
    },
    {
        "id": 2,
        "name": "애매모호한 주장"
    },
    {
        "id": 3,
        "name": "거짓말"
    },
    {
        "id": 4,
        "name": "부적절한 인증 라벨"
    }
]
```

-   ID 별 체크리스트 종류

```
1. 증거 불충분
2. 애매모호한 주장
3. 거짓말
4. 부적절한 인증 라벨
```

### 6) 예외 처리

-   HTTP 에러 코드 200, 400, 404, 500
-   응답

```json
{ "message": "" }
```
