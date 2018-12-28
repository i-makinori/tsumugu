/*

# useage
$ cat initialize.sql | sqlite3 ./tsumugu.db

*/

/*
[ref]
### https://www.sqlite.org/datatype3.html
especially:
2.2 date and time

*/

/*
### updated_at of each row
text as date
"recently-update-date, ... 1st-update-date, new-made-date"
eath date of text is such as : "YYYY-MM-DD HH:MM:SS.SSS{{+ or -}}TIME:ZOON"
*/


CREATE table observer(
       num_enuem int NOT NULL,
       cosmic_link carchar(28) NOT NULL,
       name varchar(28) NOT NULL,
       password varchar(144) NOT NULL,
       --
       email varchar(144),
       --
       UNIQUE(num_enuem, cosmic_link));


INSERT INTO observer(num_enuem, cosmic_link, name, password, email) VALUES
       (0, "tokinowari" , "tokinowari.net", "resonance", "");
INSERT INTO observer(num_enuem, cosmic_link, name, password, email) VALUES
       (1, "hacker", "someone hacked tokinowari", "dolphins", "");
INSERT INTO observer(num_enuem, cosmic_link, name, password, email) VALUES
       (2, "agent" , "someone agent", "proxy", "");


CREATE table article(
       num_enuem int NOT NULL,
       cosmic_link TEXT, -- === uri
       --
       observer_id int NOT NULL,
       authorities TEXT, -- 000 to 777 to each observer groupus
       updated_at int,
       --
       title TEXT,
       tags TEXT,
       contents TEXT,
       --
       UNIQUE(num_enuem, cosmic_link));

INSERT INTO article(num_enuem, observer_id, authorities, updated_at, cosmic_link, title, tags, contents) VALUES
       (0, 0, "", 0, "", "", "", "nil");
INSERT INTO article(num_enuem, observer_id, authorities, updated_at, cosmic_link, title, tags, contents) VALUES
       (1, 1, "", 1441000144000, "genesis", "the_genesis", "bigbang", "the not hacker spend to written this homepage more than seven universe cycles.");






CREATE table blobs(
       -- (self.id) is also pointerd from (\c1 ::= (1-row-of (article::table))).contents
       -- if (c1.tags contain "*blob*")
       --
       num_enuem int NOT NULL,
       cosmic_link TEXT, -- file name
       bytearray_contents BLOB,
       --
       UNIQUE(num_enuem, cosmic_link));

INSERT INTO blobs(num_enuem, cosmic_link, bytearray_contents) VALUES
       (0, "test_image.png", "");
;;
