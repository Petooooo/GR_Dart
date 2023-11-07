const fs = require("fs");
const mysql = require("mysql");
const express = require("express");

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

app.get("/", (request, response) => {
    response.send(`<h1>Main Page</h1>`);
});

// [API]     Product Search API
// [GET]     http://domain:8081/product/search?keyword=${keyword}&page=${page}&size=${size}
// [Example] http://localhost:8081/product/search?keyword=종이컵&page=1&size=5
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

// [API]     Product Detail Content API
// [GET]     http://domain:8081/product/detail/content?id=${id}
// [Example] http://localhost:8081/product/detail/content?id=13078030340
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
app.get("/product/review/content", (request, response) => {
    id = request.query.id;
    page = request.query.page;
    size = request.query.size;
    connection.query(
        "SELECT name, check_1, check_2, check_3, check_4, content FROM reviewTable WHERE FK_itemTable = '" +
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

// 404 Error Handler
app.use(function (req, res, next) {
    res.status(404).send("404 Error: Page Not Found");
});

// Start Server on Port ${portnum}
app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
