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

// Item Search API
// [GET] http://domain:8081/product?keyword=${keyword}&page=${page}&size=${size}
app.get("/product", (request, response) => {
    var str = "";
    keyword = request.query.keyword;
    page = request.query.page;
    size = request.query.size;
    connection.query(
        "SELECT * FROM itemTable WHERE keyword = '" + keyword + "'",
        function (error, results, fields) {
            if (error) throw error;
            var result = new Array();
            for (var i = 0; i < size; i++) {
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

app.use((request, response) => {
    response.send(`<h1>Wrong Access</h1>`);
});

app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
