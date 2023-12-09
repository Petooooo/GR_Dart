[<img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=Node.js&logoColor=white">](https://nodejs.org/)
[<img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=Express&logoColor=white">](https://expressjs.com/)
[<img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white">](https://dart.dev/)
[<img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white">](https://flutter.dev)

# 그린리버 (Green Reviewer)

사용자의 리뷰를 통해 그린워싱 제품의 위험도를 판단하고 이를 사용자가 확인할 수 있도록 하여 그린워싱으로 인한 피해를 줄일 수 있도록 도움을 주는 웹/앱입니다.

## About The Project

### Overview

<div align="center"><img width="1840" alt="web_1" src="https://github.com/Petooooo/GR_Dart/assets/87960694/8765b507-d0a6-489e-bceb-80be8da5e944"></div>

<div align="center"><img width="600" alt="app_1" src="https://github.com/Petooooo/GR_Dart/assets/87960694/bb87a291-6242-450a-9629-377891b75c68"></div>

### Project Architecture

![project_architecture](https://github.com/Petooooo/GR_Dart/assets/87960694/66deec48-7fa6-4e1c-89b2-340a5d1e012a)

### Built With

-   [Node.js](https://nodejs.org/)
-   [Express](https://expressjs.com/)
-   [Dart](https://dart.dev/)
-   [Flutter](https://flutter.dev)

## Getting Started

### Prerequisites

-   `GR_Dart/Server/ConversionServer/env.json`

```json
{
    "dbserver_host": "INPUT_DATABASE_SERVER_HOST",
    "dbserver_port": "INPUT_DATABASE_SERVER_PORT"
}
```

-   `GR_Dart/Server/FacadeServer/env.json`

```json
{
    "dbserver_host": "INPUT_DATABASE_SERVER_HOST",
    "dbserver_port": "INPUT_DATABASE_SERVER_PORT",
    "convserver_host": "INPUT_CONVERSION_SERVER_HOST",
    "convserver_port": "INPUT_CONVERSION_SERVER_PORT"
}
```

-   `GR_Dart/Server/Database/env.json`

```json
{
    "host": "INPUT_MYSQL_IP",
    "port": "INPUT_MYSQL_PORT",
    "user": "INPUT_USER_ID",
    "pw": "INPUT_PASSWORD",
    "db": "INPUT_DB_NAME"
}
```

-   `GR_Dart/Server/DatabaseServer/env.json`

```json
{
    "host": "INPUT_MYSQL_IP",
    "port": "INPUT_MYSQL_PORT",
    "user": "INPUT_USER_ID",
    "pw": "INPUT_PASSWORD",
    "db": "INPUT_DB_NAME"
}
```

### Installation Server Manually

1. Clone the repository

```shell
git clone https://github.com/Petooooo/GR_Dart.git
```

2. Write your env info that you get in prerequisite to

```shell
GR_Dart/Server/ConversionServer/env.json
GR_Dart/Server/FacadeServer/env.json
GR_Dart/Server/Database/env.json
GR_Dart/Server/DatabaseServer/env.json
```

3. Install npm packages

```shell
npm install
```

4. Open Server

```shell
npm start
```

5. Connect http://localhost:8080

### Installation Server Using Docker

1. Open terminal and navigate to the path

```shell
cd GR_Dart/Server/
```

2. Use docker compose

```shell
docker compose up -d
```

3. Connect http://localhost:8080

### Installation Client

1. Open terminal and navigate to the path

```shell
cd GR_Dart/Client/green_reviewer/
```

2. Run flutter using your device or web

```shell
flutter run -d chrome
```

## Usages

### Web Service

-   Click the **[link](http://client.green-reviewer.kro.kr)**(client.green-reviewer.kro.kr)

### Mobile Service

-   Download APK from **[here](https://drive.google.com/file/d/1t814ux4SP5uBB2-RCnbBg4DHGcPghQH1/view?usp=share_link)** or Google Play Store

## Contributing

다음 과정을 통해 프로젝트에 기여할 수 있습니다.

1. Fork the project repository
2. Create your branch (git checkout feature/name)
3. Make changes and commit (git commit -m "Input your commit contents")
4. Push to your own Gibhub repository (git push origin feature/name)
5. Create a pull request

## Contact

-   박지환: peto@khu.ac.kr
