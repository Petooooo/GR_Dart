const fs = require("fs");
const mysql = require("mysql");
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8081;

const conn = {
    host: envData.host,
    port: envData.port,
    user: envData.user,
    password: envData.pw,
    database: envData.db,
};

var connection = mysql.createConnection(conn); // Create DB Connection
connection.connect(); // Connect DB

// Using Middleware
app.use(cors());
app.use(bodyParser.json());

// CORS Response Setting
app.options("*", cors());

// HTTP Server
app.get("/", (request, response) => {
    response.send(`<h1>Main Page</h1>`);
});

// [API]     Product Search API
// [GET]     http://dbserver:8081/search?keyword=${keyword}&page=${page}&size=${size}
// [Example] http://localhost:8081/search?keyword=종이컵&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8081/search?keyword=%EC%A2%85%EC%9D%B4%EC%BB%B5&page=1&size=5"
app.get("/search", (request, response) => {
    keyword = request.query.keyword;
    page = request.query.page;
    size = request.query.size;
    connection.query(
        "SELECT * FROM itemTable WHERE keyword = '" + keyword + "'",
        function (error, results, fields) {
            if (error) throw error;
            var result = new Array();
            for (var i = 0; i < size && results[i + (page - 1) * size] != undefined; i++) {
                try {
                    var data = new Object();
                    product = results[i + (page - 1) * size];
                    data.id = product.id;
                    data.picThumbnail = product.picUrl;
                    data.name = product.name;
                    data.vendor = product.vendor;
                    data.price = product.price;
                    data.reviewer = product.reviewer;
                    data.checklists = product.checklists;
                    result.push(data);
                } catch (e) {
                    console.log(e);
                }
            }
            response.json(JSON.stringify(result));
        }
    );
});

// [API]     Product Length API
// [GET]     http://dbserver:8081/length?keyword=${keyword}
// [Example] http://localhost:8081/length?keyword=종이컵
// [cUrl]    curl -X GET "http://localhost:8081/length?keyword=%EC%A2%85%EC%9D%B4%EC%BB%B5"
app.get("/length", (request, response) => {
    keyword = request.query.keyword;
    connection.query(
        "SELECT COUNT(*) FROM itemTable WHERE keyword = '" + keyword + "'",
        function (error, results, fields) {
            if (error) throw error;
            var data = new Object();
            try {
                data.length = results[0]["COUNT(*)"];
            } catch (e) {
                console.log(e);
            }
            response.json(JSON.stringify(data));
        }
    );
});

// [API]     Product Keywords API
// [GET]     http://dbserver:8081/keywords
// [Example] http://localhost:8081/keywords
// [cUrl]    curl -X GET "http://localhost:8081/keywords"
app.get("/keywords", (request, response) => {
    connection.query("SELECT DISTINCT keyword FROM itemTable", function (error, results, fields) {
        if (error) throw error;
        var data = new Object();
        var arr = new Array();
        try {
            for (var i = 0; results[i] != undefined; i++) {
                arr.push(results[i].keyword);
            }
        } catch (e) {
            console.log(e);
        }
        data.keywords = arr;
        response.json(JSON.stringify(data));
    });
});

// [API]     Product Detail Content API
// [GET]     http://dbserver:8081/detail/content?id=${id}
// [Example] http://localhost:8081/detail/content?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/detail/content?id=13078030340"
app.get("/detail/content", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT * FROM itemTable WHERE id = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            var data = new Object();
            try {
                data.id = results[0].id;
                data.name = results[0].name;
                data.vendor = results[0].vendor;
                data.price = results[0].price;
                data.deliveryFee = results[0].deliveryFee;
                data.picUrl = results[0].picUrl;
                data.originalUrl = results[0].originalUrl;
                data.checklists = results[0].checklists;
            } catch (e) {
                console.log(e);
            }
            response.json(JSON.stringify(data));
        }
    );
});

// [API]     Product Detail Image API
// [GET]     http://dbserver:8081/detail/image?id=${id}
// [Example] http://localhost:8081/detail/image?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/detail/image?id=13078030340"
app.get("/detail/image", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT detailpicUrl FROM detailpicTable WHERE FK_itemTable = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            var data = new Object();
            var arr = new Array();
            try {
                for (var i = 0; results[i] != undefined; i++) {
                    arr.push(results[i].detailpicUrl);
                }
            } catch (e) {
                console.log(e);
            }
            data.detailpicUrl = arr;
            response.json(JSON.stringify(data));
        }
    );
});

// [API]     Product Review Length API
// [GET]     http://dbserver:8081/review/length?id=${id}
// [Example] http://localhost:8081/review/length?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/review/length?id=13078030340"
app.get("/review/length", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT COUNT(*) FROM reviewTable WHERE FK_itemTable = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            var data = new Object();
            try {
                data.length = results[0]["COUNT(*)"];
            } catch (e) {
                console.log(e);
            }
            response.json(JSON.stringify(data));
        }
    );
});

// [API]     Product Review Content API
// [GET]     http://dbserver:8081/review/content?id=${id}&page=${page}&size=${size}
// [Example] http://localhost:8081/review/content?id=13078030340&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8081/review/content?id=13078030340&page=1&size=5"
app.get("/review/content", (request, response) => {
    id = request.query.id;
    page = request.query.page;
    size = request.query.size;
    connection.query(
        "SELECT id, name, check_1, check_2, check_3, check_4, content FROM reviewTable WHERE FK_itemTable = '" +
            id +
            "'",
        function (error, results, fields) {
            if (error) throw error;
            var result = new Array();
            for (var i = 0; i < size && results[i + (page - 1) * size] != undefined; i++) {
                try {
                    var data = new Object();
                    var checklists = new Array();
                    review = results[i + (page - 1) * size];
                    data.review_id = review.id;
                    data.name = review.name;
                    data.content = review.content;
                    checklists.push(review.check_1);
                    checklists.push(review.check_2);
                    checklists.push(review.check_3);
                    checklists.push(review.check_4);
                    data.checklists = checklists;
                    result.push(data);
                } catch (e) {
                    console.log(e);
                }
            }
            response.json(JSON.stringify(result));
        }
    );
});

// [API]     Product Review Write API
// [POST]    http://dbserver:8081/review/write
// [Example] http://localhost:8081/review/write
// [cUrl]    curl -d '{"id":"13078030340","name":"John","password":"1234","check_1":1,"check_2":1,"check_3":0,"check_4":1,"content":"This is bad product."}' -H "Content-Type: application/json" -X POST "http://localhost:8081/review/write"
app.post("/review/write", (request, response) => {
    product_id = request.body.id;
    user_name = request.body.name;
    user_password = request.body.password;
    check_1 = request.body.check_1;
    check_2 = request.body.check_2;
    check_3 = request.body.check_3;
    check_4 = request.body.check_4;
    content = request.body.content;
    try {
        connection.query(
            "INSERT INTO reviewTable(name,password,check_1,check_2,check_3,check_4,content,FK_itemTable) VALUES('" +
                user_name +
                "','" +
                user_password +
                "','" +
                check_1 +
                "','" +
                check_2 +
                "','" +
                check_3 +
                "','" +
                check_4 +
                "','" +
                content +
                "','" +
                product_id +
                "')",
            function (error, results, fields) {
                if (error) throw error;
                response.send("success");
            }
        );
    } catch (e) {
        console.log(e);
    }
});

// [API]     Product Item Table Update API
// [PUT]     http://dbserver:8081/update
// [Example] http://localhost:8081/update
// [cUrl]    curl -d '{"id":"13078030340","check_1":3,"check_2":2,"check_3":1,"check_4":5,"reviewer":14}' -H "Content-Type: application/json" -X PUT "http://localhost:8081/update"
app.put("/update", (request, response) => {
    product_id = request.body.id;
    var checklists = new Array();
    checklists.push(request.body.check_1);
    checklists.push(request.body.check_2);
    checklists.push(request.body.check_3);
    checklists.push(request.body.check_4);
    reviewer = request.body.reviewer;
    try {
        connection.query(
            "UPDATE itemTable SET reviewer = '" +
                JSON.stringify(reviewer) +
                "', checklists = '" +
                JSON.stringify(checklists) +
                "' WHERE id = " +
                product_id,
            function (error, results, fields) {
                if (error) throw error;
                response.send("success");
            }
        );
    } catch (e) {
        console.log(e);
    }
});

// [API]     Product Review Delete API
// [DELETE]  http://dbserver:8081/review/delete?id=${review_id}
// [Example] http://localhost:8081/review/delete?id=1
// [cUrl]    curl -X DELETE "http://localhost:8081/review/delete?id=1"
app.delete("/review/delete", (request, response) => {
    id = request.query.id;
    try {
        connection.query(
            "DELETE FROM reviewTable WHERE id = " + id,
            function (error, results, fields) {
                if (error) throw error;
                response.send("success");
            }
        );
    } catch (e) {
        console.log(e);
    }
});

// [API]     Product Review Password API
// [GET]     http://dbserver:8081/review/password?id=${review_id}
// [Example] http://localhost:8081/review/password?id=20
// [cUrl]    curl -X GET "http://localhost:8081/review/password?id=20"
app.get("/review/password", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT password FROM reviewTable WHERE id = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            response.json(JSON.stringify(results[0]));
        }
    );
});

// [API]     Product Review Checklist API
// [GET]     http://dbserver:8081/review/checklist?id=${review_id}
// [Example] http://localhost:8081/review/checklist?id=20
// [cUrl]    curl -X GET "http://localhost:8081/review/checklist?id=19"
app.get("/review/checklist", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT check_1,check_2,check_3,check_4 FROM reviewTable WHERE id = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            response.json(results[0]);
        }
    );
});

// 404 Error Handler
app.use(function (req, res, next) {
    res.status(404).send("404 Error: Page Not Found");
});

// Start Server on Port ${portnum}
app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
