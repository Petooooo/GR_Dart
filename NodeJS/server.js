const express = require("express");
const app = express();
const portnum = 8081;

function callback(error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log(body);
    }
}

app.get("/", (request, response) => { 
  response.send(`<h1>Main Page</h1>`);
  console.log(request(options, callback));
});

app.use((request, response) => {
  response.send(`<h1>Page not found</h1>`);
});

app.listen(portnum, () => {
  console.log("Listening on " + portnum);
});