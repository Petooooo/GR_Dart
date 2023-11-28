const fs = require("fs");
const express = require("express");
const bodyParser = require("body-parser");
const request = require("request");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8080;

// Body Parser Middleware
app.use(bodyParser.json());

app.get("/", (request, response) => {
    response.send(`<h1>Main Page</h1>`);
});

// [API]     Detail API
// [GET]     http://facadeserver:8080/detail?id=${id}
// [Example] http://localhost:8080/detail?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8080/detail?id=13078030340"
app.get("/detail", (req, res) => {
    id = req.query.id;
    detailURL = encodeURI(
        "http://" + envData.convserver_host + ":" + envData.convserver_port + "/detail?id=" + id
    );
    request.get(
        {
            url: detailURL,
            method: "GET",
        },
        function (error, response, body) {
            res.send(body);
        }
    );
});

// [API]     Review Content API
// [GET]     http://facadeserver:8080/review/content?id=${id}&page=${page}&size=${size}
// [Example] http://localhost:8080/review/content?id=13078030340&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8080/review/content?id=13078030340&page=1&size=5"
app.get("/review/content", (req, res) => {
    request.get(
        {
            url:
                "http://" +
                envData.dbserver_host +
                ":" +
                envData.dbserver_port +
                "/review/content?id=" +
                req.query.id +
                "&page=" +
                req.query.page +
                "&size=" +
                req.query.size,
            method: "GET",
        },
        function (error, response, body) {
            res.send(body);
        }
    );
});

// [API]     Review Content API
// [GET]     http://facadeserver:8080/review/content?id=${id}&page=${page}&size=${size}
// [Example] http://localhost:8080/review/content?id=13078030340&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8080/review/content?id=13078030340&page=1&size=5"
app.get("/review/content", (req, res) => {
    request.get(
        {
            url:
                "http://" +
                envData.dbserver_host +
                ":" +
                envData.dbserver_port +
                "/review/content?id=" +
                req.query.id +
                "&page=" +
                req.query.page +
                "&size=" +
                req.query.size,
            method: "GET",
        },
        function (error, response, body) {
            res.send(body);
        }
    );
});

// [API]     Review Write API
// [POST]    http://facadeserver:8080/review/write
// [Example] http://localhost:8080/review/write
// [cUrl]    curl -d '{"id":"13078030340","name":"John","password":"1234","checklists": [1, 1, 0, 1],"content":"This is bad product."}' -H "Content-Type: application/json" -X POST "http://localhost:8080/review/write"
app.post("/review/write", (req, res) => {
    product_id = req.body.id;
    user_name = req.body.name;
    user_password = req.body.password;
    checklists = req.body.checklists;
    content = req.body.content;
    reviewWriteURL = encodeURI(
        "http://" + envData.convserver_host + ":" + envData.convserver_port + "/review/write"
    );
    request.post(
        {
            uri: reviewWriteURL,
            method: "POST",
            body: {
                id: product_id,
                name: user_name,
                password: user_password,
                checklists: checklists,
                content: content,
            },
            json: true,
        },
        function (error, response, body) {
            res.send(body);
        }
    );
});

// [API]     Review Delete API
// [DELETE]  http://facadeserver:8080/review/delete?id=${review_id}
// [Example] http://localhost:8080/review/delete?id=1
// [cUrl]    curl -X DELETE "http://localhost:8080/review/delete?id=1"
app.delete("/review/delete", (req, res) => {
    request.delete(
        {
            url:
                "http://" +
                envData.dbserver_host +
                ":" +
                envData.dbserver_port +
                "/review/delete?id=" +
                req.query.id,
            method: "DELETE",
        },
        function (error, response, body) {
            res.send(body);
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
