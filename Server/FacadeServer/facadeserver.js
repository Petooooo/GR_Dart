const fs = require("fs");
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const request = require("request");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8080;

// Using Middleware
app.use(cors());
app.use(bodyParser.json());

// CORS Response Setting
app.options("*", cors());

// HTTP Server
app.get("/", (request, response) => {
  response.send(`<h1>Main Page</h1>`);
});

// [API]     Search API
// [GET]     http://facadeserver:8080/search?searchword=${searchword}&page=${page}&size=${size}
// [Example] http://localhost:8080/search?searchword=종이컵&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8080/search?searchword=%EC%A2%85%EC%9D%B4%EC%BB%B5&page=1&size=5"
app.get("/search", (req, res) => {
  searchword = req.query.searchword;
  page = req.query.page;
  size = req.query.size;
  detailURL = encodeURI(
    "http://" +
      envData.convserver_host +
      ":" +
      envData.convserver_port +
      "/search?searchword=" +
      searchword +
      "&page=" +
      page +
      "&size=" +
      size
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

// [API]     Detail API
// [GET]     http://facadeserver:8080/detail?id=${id}
// [Example] http://localhost:8080/detail?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8080/detail?id=13078030340"
app.get("/detail", (req, res) => {
  id = req.query.id;
  detailURL = encodeURI(
    "http://" +
      envData.convserver_host +
      ":" +
      envData.convserver_port +
      "/detail?id=" +
      id
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

// [API]     Search Length API
// [GET]     http://facadeserver:8080/search/length?searchword=${searchword}
// [Example] http://localhost:8080/search/length?searchword=종이컵
// [cUrl]    curl -X GET "http://localhost:8080/search/length?searchword=%EC%A2%85%EC%9D%B4%EC%BB%B5"
app.get("/search/length", (req, res) => {
  searchword = req.query.searchword;
  lengthURL = encodeURI(
    "http://" +
      envData.convserver_host +
      ":" +
      envData.convserver_port +
      "/search/length?searchword=" +
      req.query.searchword
  );
  request.get(
    {
      url: lengthURL,
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
    "http://" +
      envData.convserver_host +
      ":" +
      envData.convserver_port +
      "/review/write"
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
// [DELETE]  http://facadeserver:8080/review/delete?product_id=${product_id}&review_id=${review_id}&password=${password}
// [Example] http://localhost:8080/review/deletedelete?product_id=13078030340&review_id=1&password=123
// [cUrl]    curl -X DELETE "http://localhost:8080/review/delete?product_id=13078030340&review_id=1&password=123"
app.delete("/review/delete", (req, res) => {
  request.delete(
    {
      url:
        "http://" +
        envData.convserver_host +
        ":" +
        envData.convserver_port +
        "/review/delete?product_id=" +
        req.query.product_id +
        "&review_id=" +
        req.query.review_id +
        "&password=" +
        req.query.password,
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
