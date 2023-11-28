const fs = require("fs");
const express = require("express");
const bodyParser = require("body-parser");
const request = require("request");
const { userInfo } = require("os");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8082;

// Function to calculate the Levenshtein distance between two strings
function levenshteinDistance(str1, str2) {
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
function getKeyword(searchword, keywords) {
    var keyword = "";
    var maxSimilarity = 0;
    for (let i = 0; i < keywords.length; i++) {
        // Calculating Levenshtein distance
        const distance = levenshteinDistance(searchword, keywords[i]);

        // Calculating the length of the longer string
        const maxLength = Math.max(searchword.length, keywords[i].length);

        // Calculating similarity
        const similarity = 1 - distance / maxLength;
        if (similarity > maxSimilarity) {
            keyword = keywords[i];
            maxSimilarity = similarity;
        }
    }
    return keyword;
}

// Body Parser Middleware
app.use(bodyParser.json());

// Http Server Threads
app.get("/", (req, res) => {
    response.send(`<h1>Main Page</h1>`);
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
            keyword = getKeyword(searchword, JSON.parse(JSON.parse(body)).keywords);
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

// 404 Error Handler
app.use(function (req, res, next) {
    res.status(404).send("404 Error: Page Not Found");
});

// Start Server on Port ${portnum}
app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
