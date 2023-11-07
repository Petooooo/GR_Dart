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
            for (var i = (page - 1) * size; i < (page - 1) * (size + 1); i++) {
                var data = new Object();
                product = results[i];
                data.id = product.id;
                data.picThumbnail = product.picThumbnail;
                data.name = product.name;
                data.vendor = product.vendor;
                data.price = product.price;
                data.reviewer = 0;
                data.checklists = [0, 0, 0, 0];
                connection.query(
                    "SELECT COUNT(*) FROM reviewTable WHERE FK_itemTable = '" + product.id + "'",
                    function (error, count, fields) {
                        if (error) throw error;
                        data.reviewer = count[0]["COUNT(*)"];
                    }
                );
                // console.log(product.id);
                connection.query(
                    "SELECT * FROM reviewTable WHERE FK_itemTable = '" + product.id + "'",
                    function (error, results, fields) {
                        if (error) throw error;
                        for (var j = 0; j < data.reviewer; j++) {
                            console.log(results[j]);
                            data.checklists[0] += results[j].check_1;
                            data.checklists[1] += results[j].check_2;
                            data.checklists[2] += results[j].check_3;
                            data.checklists[3] += results[j].check_4;
                        }
                    }
                );
                console.log(data.checklists);
            }
        }
    );
});

app.use((request, response) => {
    response.send(`<h1>Wrong Access</h1>`);
});

app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
