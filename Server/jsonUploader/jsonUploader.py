import pymysql
import json
import os

with open('./env.json', 'r') as f:
    envData = json.load(f)

try:
    db = pymysql.connect(host=envData['host'], port=int(envData['port']), user = envData['user'], password=envData['pw'], db = envData['db'],charset = 'utf8') 
    cursor = db.cursor()
    print("Connected Database")
except:
    print("Can't connect Database")
    exit()

path = os.path.join(os.path.split(os.getcwd())[0], "Webcrawler/items")
for keyword in os.listdir(path):
    if keyword == ".DS_Store":
        continue
    item_path = os.path.join(path, keyword)
    items = os.listdir(item_path)
    for item in items:
        json_path = os.path.join(item_path, item)
        try:
            with open(json_path, 'r') as f:
                jsonFile = json.load(f)
            productId = "\'" + item[:-5] + "\'"
            name = "\'" + jsonFile['name'] + "\'"
            vendor = "\'" + jsonFile['vendor'] + "\'"
            picUrl = "\'" + jsonFile['picUrl'] + "\'"
            thumbnailUrl = "\'" + jsonFile['thumbnailUrl']  + "\'"
            price = "\'" + jsonFile['price'] + "\'"
            deliveryFee = "\'" + jsonFile['deliveryFee'] + "\'"
            originalUrl = "\'" + jsonFile['originalUrl']  + "\'"
            reviewer = "\'0\'"
            checklists = "\'[0,0,0,0]\'"
            query1 = "INSERT INTO itemTable(id,name,vendor,picUrl,thumbnailUrl,price,deliveryFee,originalUrl,reviewer,checklists,keyword) VALUES(" + productId + "," + name + "," + vendor + "," + picUrl + "," + thumbnailUrl + "," + price + "," + deliveryFee + "," + originalUrl + "," + reviewer + "," + checklists + ",\'" + keyword + "\');"
            try:
                cursor.execute(query1)
            except:
                pass
            for detailUrl in jsonFile['detailpicUrl']:
                detailpicUrl = "\'" + detailUrl + "\'"
                query2 = "INSERT INTO detailpicUrlTable(detailpicUrl, FK_itemTable) VALUES(" + detailpicUrl + "," + productId + ");"
                try:
                    cursor.execute(query2)
                except:
                    pass
        except:
            pass

db.commit()
db.close()
print("Closed Database")