const fs = require("fs");
const mysql = require("mysql");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const conn = {
    // mysql 접속 설정
    host: envData.host,
    port: envData.port,
    user: envData.user,
    password: envData.pw,
    database: envData.db,
};

var connection = mysql.createConnection(conn); // DB 커넥션 생성
connection.connect(); // DB 접속

// 쿼리문

connection.end(); // DB 접속 종료
