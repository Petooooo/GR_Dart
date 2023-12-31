ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
CREATE DATABASE productInfo;
USE productInfo;
CREATE TABLE itemTable(
  id VARCHAR(11) NOT NULL,
  name VARCHAR(100) NOT NULL,
  vendor VARCHAR(100) NOT NULL,
  picUrl VARCHAR(2000) NOT NULL,
  thumbnailUrl VARCHAR(2000) NOT NULL,
  price VARCHAR(100) NOT NULL,
  deliveryFee VARCHAR(100) NOT NULL,
  originalUrl VARCHAR(2000) NOT NULL,
  reviewer VARCHAR(100) NOT NULL,
  checklists VARCHAR(100) NOT NULL,
  keyword VARCHAR(100) NOT NULL,
  CONSTRAINT itemTable_PK PRIMARY KEY(id)
);

CREATE TABLE detailpicTable (
  id INT(11) NOT NULL AUTO_INCREMENT,
  detailpicUrl VARCHAR(2000) NOT NULL,
  FK_itemTable VARCHAR(11) NOT NULL,
  CONSTRAINT detailpicUrlTable_PK PRIMARY KEY(id),
  CONSTRAINT itemTable_FK FOREIGN KEY(FK_itemTable) REFERENCES itemTable(id)
);

CREATE TABLE reviewTable (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL,
  check_1 INT(11) NOT NULL,
  check_2 INT(11) NOT NULL,
  check_3 INT(11) NOT NULL,
  check_4 INT(11) NOT NULL,
  content VARCHAR(2000) NOT NULL,
  FK_itemTable VARCHAR(11) NOT NULL,
  CONSTRAINT reviewTable_PK PRIMARY KEY(id),
  CONSTRAINT itemTable_FK2 FOREIGN KEY(FK_itemTable) REFERENCES itemTable(id)
);
