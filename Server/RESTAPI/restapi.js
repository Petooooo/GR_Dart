const fs = require("fs");
const mysql = require("mysql");
const express = require("express");
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

// Body Parser Middleware
app.use(bodyParser.json());

app.get("/", (request, response) => {
    response.send(`<h1>Main Page</h1>`);
});

// [API]     Product Search API
// [GET]     http://domain:8081/product/search?keyword=${keyword}&page=${page}&size=${size}
// [Example] http://localhost:8081/product/search?keyword=종이컵&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8081/product/search?keyword=%EC%A2%85%EC%9D%B4%EC%BB%B5&page=1&size=5"
app.get("/product/search", (request, response) => {
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
// [GET]     http://domain:8081/product/length?keyword=${keyword}
// [Example] http://localhost:8081/product/length?keyword=종이컵
// [cUrl]    curl -X GET "http://localhost:8081/product/length?keyword=%EC%A2%85%EC%9D%B4%EC%BB%B5"
app.get("/product/length", (request, response) => {
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
// [GET]     http://domain:8081/product/keywords
// [Example] http://localhost:8081/product/keywords
// [cUrl]    curl -X GET "http://localhost:8081/product/keywords"
app.get("/product/keywords", (request, response) => {
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
// [GET]     http://domain:8081/product/detail/content?id=${id}
// [Example] http://localhost:8081/product/detail/content?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/product/detail/content?id=13078030340"
app.get("/product/detail/content", (request, response) => {
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
// [GET]     http://domain:8081/product/detail/image?id=${id}
// [Example] http://localhost:8081/product/detail/image?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/product/detail/image?id=13078030340"
app.get("/product/detail/image", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT detailpicUrl FROM detailpicUrlTable WHERE FK_itemTable = '" + id + "'",
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

// [API]     Product Detail Checklist API
// [GET]     http://domain:8081/product/detail/checklist?id=${id}
// [Example] http://localhost:8081/product/detail/checklist?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8081/product/detail/checklist?id=13078030340"
app.get("/product/detail/checklist", (request, response) => {
    id = request.query.id;
    connection.query(
        "SELECT checklists FROM itemTable WHERE id = '" + id + "'",
        function (error, results, fields) {
            if (error) throw error;
            var data = new Object();
            try {
                data.checklists = results[0].checklists;
            } catch (e) {
                console.log(e);
            }
            response.json(JSON.stringify(data));
        }
    );
});

// [API]     Product Review Content API
// [GET]     http://domain:8081/product/review/content?id=${id}&page=${page}&size=${size}
// [Example] http://localhost:8081/product/review/content?id=13078030340&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8081/product/review/content?id=13078030340&page=1&size=5"
app.get("/product/review/content", (request, response) => {
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
// [POST]    http://domain:8081/product/review/write
// [Example] http://localhost:8081/product/review/write
// [cUrl]    curl -d '{"id":"13078030340","name":"John","password":"1234","check_1":1,"check_2":1,"check_3":0,"check_4":1,"content":"This is bad product."}' -H "Content-Type: application/json" -X POST "http://localhost:8081/product/review/write"
app.post("/product/review/write", (request, response) => {
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

// [API]     Update Product Item Table API
// [PUT]     http://domain:8081/product/update
// [Example] http://localhost:8081/product/update
// [cUrl]    curl -d '{"id":"13078030340","check_1":3,"check_2":2,"check_3":1,"check_4":5,"reviewer":14}' -H "Content-Type: application/json" -X PUT "http://localhost:8081/product/update"
app.put("/product/update", (request, response) => {
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

// [API]     Delete Review API
// [DELETE]  http://domain:8081/product/review/delete?id=${review_id}
// [Example] http://localhost:8081/product/review/delete?id=1
// [cUrl]    curl -X DELETE "http://localhost:8081/product/review/delete?id=1"
app.delete("/product/review/delete", (request, response) => {
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

// 404 Error Handler
app.use(function (req, res, next) {
    res.status(404).send("404 Error: Page Not Found");
});

// Start Server on Port ${portnum}
app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
