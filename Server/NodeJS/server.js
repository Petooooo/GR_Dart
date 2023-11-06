const express = require("express");
const request = require('request');

const app = express();
const portnum = 8081;

var searchTitle = encodeURI('65W 충전기');
var indexNumber = '1'
var pagingSize = '40';

var headers = {
    'authority': 'search.shopping.naver.com',
    'accept': 'application/json, text/plain, */*',
    'accept-language': 'ko,en;q=0.9,en-US;q=0.8',
    'cookie': 'NNB=O3TIYRN75BJWI; NDARK=Y; _ga=GA1.1.1296920090.1683531088; NSCS=2; ASID=b6d00056000001882922bd5b0000004b; _ga_YTT2922408=GS1.1.1686186928.24.0.1686186928.0.0.0; nid_inf=-1585989471; NID_AUT=BGcISGIMNZbHE8CctWcnNuKaal3OWxme5R8Uy7hax1rkNd94qzbpmtWIfop5IHVy; NID_JKL=sUDleQjSM+82HbSzr91pIz3gqPuVwGDAPyT2TU04Wlg=; nx_ssl=2; SHP_BUCKET_ID=4; NID_SES=AAABsi1ouNlMsNggn5ONxiwnzuP55x6CZnEr9ojjSsBlNpNDfr6ERLz5Mf0n3Sr240uw9Fq+8VynFbzrhRIDnNFBwh+XQrOFWgw9ri5LPm0eFTUqanmzmPkcZMXrUvhmYU0E1o5g7fqv2xFlrm9RKnVEqcMWB4j7V575qGQqTmHeet+0zyz9Gwd3fNU/Obx5ygnLMykkuJgqLW26KMiEITI6V/HCSPn5w1yMPNEj6XuqDRYaNipUV/ZUs0e3OP4t6Eeu2YMEoENE46SWnB2CpBUorvdwbJtTDQ1e1OzzGOAVtmbJw8Fv3QwS1D4g7FqJQUEW3kSp+R1xI34ywhWX5dMHwGSjI1m5S7PwVtefv0sFr7UYaw630d0+qR8hOQCUmK24cM09oRGZvhyrXOR8Sb3Gvs39w4Gy7KooFP+saGyc5e2yHViMuWJXklELgAgjkNjA8Qocfq5ZdGMAhwNyxe5kkCR4YSGKm0u1qNQuPRUXMINcO2/jfDepieA719jKONCTp11hTq+oBlKSYQQl7UiGr3sMdu8n4mwMxgrLNPV2clgMwhUYl8gxeDho4E5+4OZYDg0i4CaH7P0DD0yuvC4kyNk=; page_uid=idZLPlp0YihssEHr7osssssssxh-338542; spage_uid=idZLPlp0YihssEHr7osssssssxh-338542',
    'logic': 'PART',
    'referer': 'https://search.shopping.naver.com/search/all?query=' + searchTitle + '&prevQuery=' + searchTitle,
    'sbth': 'd5814761e7a0044d30810f8908faa738a3b15d4355ec07198c0a5f2749947b752207ed38c7e08471477fe14f8a89522f',
    'sec-ch-ua': '"Chromium";v="116", "Not)A;Brand";v="24", "Microsoft Edge";v="116"',
    'sec-ch-ua-arch': '"x86"',
    'sec-ch-ua-bitness': '"64"',
    'sec-ch-ua-full-version-list': '"Chromium";v="116.0.5845.141", "Not)A;Brand";v="24.0.0.0", "Microsoft Edge";v="116.0.1938.69"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-model': '""',
    'sec-ch-ua-platform': '"Windows"',
    'sec-ch-ua-platform-version': '"10.0.0"',
    'sec-ch-ua-wow64': '?0',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.69'
};

var options = {
    url: 'https://search.shopping.naver.com/api/search/all?eq=&iq=&origQuery=' + searchTitle + '&pagingIndex=' + indexNumber + '&pagingSize=' + pagingSize + '&productSet=total&query='+ searchTitle +'&sort=rel&viewType=list&xq=',
    headers: headers
};

function callback(error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log(body);
    }
}

request(options, callback);

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