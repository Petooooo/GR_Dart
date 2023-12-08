const express = require("express");
const app = express();
const portnum = 80;

app.use(express.static(__dirname));

app.get("/", (req, res) => {
    res.sendFile(__dirname + "/index.html");
});

app.listen(portnum, () => {
    console.log("Listening on " + portnum);
});
