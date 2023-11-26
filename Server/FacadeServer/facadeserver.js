const express = require("express");
const bodyParser = require("body-parser");
const request = require("request");

const envFile = fs.readFileSync("./env.json", "utf8");
const envData = JSON.parse(envFile);

const app = express();
const portnum = 8081;

// Body Parser Middleware
app.use(bodyParser.json());

app.get("/", (request, response) => {
    response.send(`<h1>Main Page</h1>`);
});

// 404 Error Handler
app.use(function (req, res, next) {
    res.status(404).send("404 Error: Page Not Found");
});

// Start Server on Port ${portnum}
app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
