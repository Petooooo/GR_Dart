const fs = require("fs");
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const request = require("request");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8082;

// Transformer Class (Searchword to Keyword)
class Transformer {
    // Constructor
    constructor(searchword, keywords) {
        this.searchword = searchword;
        this.keywords = keywords;
        this.keyword = "";
    }

    // Function to calculate the Levenshtein distance between two strings
    levenshteinDistance(str1, str2) {
        const m = str1.length;
        const n = str2.length;

        // Handling empty strings
        if (m === 0) return n;
        if (n === 0) return m;

        // Initializing a 2D array
        const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));

        // Setting initial values
        for (let i = 0; i <= m; i++) {
            dp[i][0] = i;
        }
        for (let j = 0; j <= n; j++) {
            dp[0][j] = j;
        }

        // Calculating the edit distance
        for (let i = 1; i <= m; i++) {
            for (let j = 1; j <= n; j++) {
                const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
                dp[i][j] = Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost);
            }
        }
        return dp[m][n];
    }

    // Function to find the most similar keyword to a search word in a list of keywords
    transKeyword() {
        var keyword = "";
        var maxSimilarity = 0;
        for (let i = 0; i < this.keywords.length; i++) {
            // Calculating Levenshtein distance
            const distance = this.levenshteinDistance(this.searchword, this.keywords[i]);

            // Calculating the length of the longer string
            const maxLength = Math.max(this.searchword.length, this.keywords[i].length);

            // Calculating similarity
            const similarity = 1 - distance / maxLength;
            if (similarity > maxSimilarity) {
                keyword = this.keywords[i];
                maxSimilarity = similarity;
            }
        }
        this.keyword = keyword;
    }

    // Get Keyword Function
    getKeyword() {
        return this.keyword;
    }
}

// Using Middleware
app.use(cors());
app.use(bodyParser.json());

// CORS Response Setting
app.options("*", cors());

// HTTP Server
app.get("/", (req, res) => {
    res.send(`<h1>Main Page</h1>`);
});

// [API]     Product Search API
// [GET]     http://conversionserver:8082/search?searchword=${searchword}&page=${page}&size=${size}
// [Example] http://localhost:8082/search?searchword=종이컵&page=1&size=5
// [cUrl]    curl -X GET "http://localhost:8082/search?searchword=%EC%A2%85%EC%9D%B4%EC%BB%B5&page=1&size=5"
app.get("/search", (req, res) => {
    searchword = req.query.searchword;
    page = req.query.page;
    size = req.query.size;
    keywordURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/keywords"
    );
    request.get(
        {
            url: keywordURL,
            method: "GET",
        },
        function (error, response, body) {
            trans = new Transformer(searchword, JSON.parse(JSON.parse(body)).keywords);
            trans.transKeyword();
            keyword = trans.getKeyword();
            searchURL = encodeURI(
                "http://" +
                    envData.dbserver_host +
                    ":" +
                    envData.dbserver_port +
                    "/search?keyword=" +
                    keyword +
                    "&page=" +
                    page +
                    "&size=" +
                    size
            );
            request.get(
                {
                    url: searchURL,
                    method: "GET",
                },
                function (error, response, body) {
                    res.send(JSON.parse(body));
                }
            );
        }
    );
});

// [API]     Product Detail API
// [GET]     http://conversionserver:8082/detail?id=${id}
// [Example] http://localhost:8082/detail?id=13078030340
// [cUrl]    curl -X GET "http://localhost:8082/detail?id=13078030340"
app.get("/detail", (req, res) => {
    id = req.query.id;
    contentURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/detail/content?id=" + id
    );
    imageURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/detail/image?id=" + id
    );
    request.get(
        {
            url: contentURL,
            method: "GET",
        },
        function (error1, response1, body1) {
            request.get(
                {
                    url: imageURL,
                    method: "GET",
                },
                function (error2, response2, body2) {
                    result = JSON.parse(JSON.parse(body1));
                    result.detailpicUrl = JSON.parse(JSON.parse(body2)).detailpicUrl;
                    res.send(JSON.stringify(result));
                }
            );
        }
    );
});

// [API]     Product Review Write API
// [POST]    http://conversionserver:8082/review/write
// [Example] http://localhost:8082/review/write
// [cUrl]    curl -d '{"id":"13078030340","name":"John","password":"1234","checklists": [1, 1, 0, 1],"content":"This is bad product."}' -H "Content-Type: application/json" -X POST "http://localhost:8082/review/write"
app.post("/review/write", (req, res) => {
    product_id = req.body.id;
    user_name = req.body.name;
    user_password = req.body.password;
    check_1 = req.body.checklists[0];
    check_2 = req.body.checklists[1];
    check_3 = req.body.checklists[2];
    check_4 = req.body.checklists[3];
    content = req.body.content;
    detailURL = encodeURI(
        "http://" +
            envData.dbserver_host +
            ":" +
            envData.dbserver_port +
            "/detail/content?id=" +
            product_id
    );
    reviewWriteURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/review/write"
    );
    reviewLengthURL = encodeURI(
        "http://" +
            envData.dbserver_host +
            ":" +
            envData.dbserver_port +
            "/review/length?id=" +
            product_id
    );
    updateURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/update"
    );
    request.get(
        {
            url: detailURL,
            method: "GET",
        },
        function (error1, response1, body1) {
            old_checklists = JSON.parse(JSON.parse(JSON.parse(body1)).checklists);
            new_checklists = [
                old_checklists[0] + check_1,
                old_checklists[1] + check_2,
                old_checklists[2] + check_3,
                old_checklists[3] + check_4,
            ];
            request.post(
                {
                    uri: reviewWriteURL,
                    method: "POST",
                    body: {
                        id: product_id,
                        name: user_name,
                        password: user_password,
                        check_1: check_1,
                        check_2: check_2,
                        check_3: check_3,
                        check_4: check_4,
                        content: content,
                    },
                    json: true,
                },
                function (error2, response2, body2) {
                    request.get(
                        {
                            url: reviewLengthURL,
                            method: "GET",
                        },
                        function (error3, response3, body3) {
                            new_length = JSON.parse(JSON.parse(body3)).length;
                            request.put(
                                {
                                    uri: updateURL,
                                    method: "PUT",
                                    body: {
                                        id: product_id,
                                        check_1: new_checklists[0],
                                        check_2: new_checklists[1],
                                        check_3: new_checklists[2],
                                        check_4: new_checklists[3],
                                        reviewer: new_length,
                                    },
                                    json: true,
                                },
                                function (error2, response4, body4) {
                                    res.send("sucess");
                                }
                            );
                        }
                    );
                }
            );
        }
    );
});

// [API]     Product Review Delete API
// [DELETE]  http://conversionserver:8082/review/delete?id=${review_id}&password=${password}
// [Example] http://localhost:8082/review/delete?id=1&password=123
// [cUrl]    curl -X DELETE "http://localhost:8082/review/delete?id=1&password=1234"
app.delete("/review/delete", (req, res) => {
    review_id = req.query.id;
    password = req.query.password;
    reviewPasswordURL = encodeURI(
        "http://" +
            envData.dbserver_host +
            ":" +
            envData.dbserver_port +
            "/review/password?id=" +
            review_id
    );
    reviewDeleteURL = encodeURI(
        "http://" +
            envData.dbserver_host +
            ":" +
            envData.dbserver_port +
            "/review/delete?id=" +
            review_id
    );
    request.get(
        {
            url: reviewPasswordURL,
            method: "GET",
        },
        function (error1, response1, body1) {
            if (password == JSON.parse(JSON.parse(body1)).password) {
                request.delete(
                    {
                        url: reviewDeleteURL,
                    },
                    function (error2, response2, body2) {
                        res.send(body2);
                    }
                );
            } else {
                res.send("WrongPassword");
            }
        }
    );
});

// [API]     Product Search Length API
// [GET]     http://conversionserver:8082/search/length?searchword=${searchword}
// [Example] http://localhost:8082/search/length?searchword=종이컵
// [cUrl]    curl -X GET "http://localhost:8082/search/length?searchword=%EC%A2%85%EC%9D%B4%EC%BB%B5"
app.get("/search/length", (req, res) => {
    searchword = req.query.searchword;
    keywordURL = encodeURI(
        "http://" + envData.dbserver_host + ":" + envData.dbserver_port + "/keywords"
    );
    request.get(
        {
            url: keywordURL,
            method: "GET",
        },
        function (error1, response1, body1) {
            trans = new Transformer(searchword, JSON.parse(JSON.parse(body1)).keywords);
            trans.transKeyword();
            keyword = trans.getKeyword();
            lengthURL = encodeURI(
                "http://" +
                    envData.dbserver_host +
                    ":" +
                    envData.dbserver_port +
                    "/length?keyword=" +
                    keyword
            );
            request.get(
                {
                    url: lengthURL,
                    method: "GET",
                },
                function (error2, response2, body2) {
                    res.send(JSON.parse(body2));
                }
            );
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
